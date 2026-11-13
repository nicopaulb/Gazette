"""Security tests for the PocketBase schema (pocketbase/pb_schema.json).

Starts a throwaway PocketBase instance, imports the schema, seeds users,
editions and anecdotes, then checks every access rule as an anonymous
visitor, a family member and an admin ("priviliged" user).

Usage:
    python tests/security/test_pb_rules.py --pocketbase /path/to/pocketbase [--schema pocketbase/pb_schema.json]

Exit code is 0 when every check passes, 1 otherwise.
"""

import argparse
import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

PORT = 18090
BASE = "http://127.0.0.1:%d" % PORT
SU_EMAIL = "superuser@test.local"
SU_PASSWORD = "superuser-password-123"
PASSWORD = "family-pass-123"  # the app login field accepts 16 characters max

PNG = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
)
PDF = b"%PDF-1.4\n1 0 obj<</Type/Catalog>>endobj\ntrailer<</Root 1 0 R>>\n%%EOF\n"
HTML = b"<html><body><script>alert(document.cookie)</script></body></html>"


# ---------------------------------------------------------------- HTTP helpers

def request(method, path, token=None, data=None, files=None, raw=False):
    """Sends a JSON or multipart request, returns (status, parsed body)."""
    headers = {}
    body = None
    if token:
        headers["Authorization"] = token
    if files is not None:
        boundary = uuid.uuid4().hex
        parts = []
        for key, value in (data or {}).items():
            parts.append(
                ("--%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n" % (boundary, key, value)).encode()
            )
        for key, (filename, content) in files.items():
            parts.append(
                ("--%s\r\nContent-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\n"
                 "Content-Type: application/octet-stream\r\n\r\n" % (boundary, key, filename)).encode()
                + content + b"\r\n"
            )
        parts.append(("--%s--\r\n" % boundary).encode())
        body = b"".join(parts)
        headers["Content-Type"] = "multipart/form-data; boundary=" + boundary
    elif data is not None:
        body = json.dumps(data).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(BASE + path, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=10) as rsp:
            content = rsp.read()
            status = rsp.status
    except urllib.error.HTTPError as e:
        content = e.read()
        status = e.code
    if raw:
        return status, content
    try:
        return status, json.loads(content) if content else None
    except ValueError:
        return status, content


def auth(collection, identity, password):
    status, body = request("POST", "/api/collections/%s/auth-with-password" % collection,
                           data={"identity": identity, "password": password})
    if status != 200:
        raise RuntimeError("auth failed for %s: %s %s" % (identity, status, body))
    return body["token"]


def file_url(record, field, token=None, thumb=None):
    params = {}
    if thumb:
        params["thumb"] = thumb
    if token:
        params["token"] = token
    path = "/api/files/%s/%s/%s" % (record["collectionId"], record["id"], record[field])
    return path + ("?" + urllib.parse.urlencode(params) if params else "")


# ---------------------------------------------------------------- test harness

results = []


def check(name, ok, detail=""):
    results.append((name, ok, detail))
    print("%s  %s%s" % ("PASS" if ok else "FAIL", name, ("  (" + detail + ")") if detail else ""))


def list_ids(collection, token=None, query=""):
    status, body = request("GET", "/api/collections/%s/records?perPage=200%s" % (collection, query), token)
    if status != 200:
        return status, set()
    return status, {r["id"] for r in body["items"]}


# ---------------------------------------------------------------- setup

def start_pocketbase(binary, data_dir):
    subprocess.run([binary, "superuser", "upsert", SU_EMAIL, SU_PASSWORD, "--dir", data_dir],
                   check=True, capture_output=True)
    proc = subprocess.Popen([binary, "serve", "--http", "127.0.0.1:%d" % PORT, "--dir", data_dir],
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(50):
        try:
            if request("GET", "/api/health")[0] == 200:
                return proc
        except OSError:
            pass
        time.sleep(0.2)
    proc.kill()
    raise RuntimeError("PocketBase did not start")


def import_schema(su, schema_path, merge):
    """merge=False matches a fresh install (dashboard "Merge" unchecked),
    merge=True matches an upgrade of an existing instance ("Merge" checked)."""
    with open(schema_path, encoding="utf-8") as f:
        collections = json.load(f)
    status, body = request("PUT", "/api/collections/import", su,
                           data={"collections": collections, "deleteMissing": not merge})
    if status != 204:
        raise RuntimeError("schema import failed: %s %s" % (status, body))


def seed(schema_path, upgrade_from=None):
    su = auth("_superusers", SU_EMAIL, SU_PASSWORD)
    import_schema(su, upgrade_from or schema_path, merge=False)

    users = {}
    for name, admin in (("admin", True), ("alice", False), ("bob", False)):
        status, body = request("POST", "/api/collections/users/records", su, data={
            "username": name, "email": name + "@test.local", "password": PASSWORD,
            "passwordConfirm": PASSWORD, "firstname": name.capitalize(), "lastname": "Test",
            "priviliged": admin}, files={"avatar": (name + ".png", PNG)})
        if status != 200:
            raise RuntimeError("user creation failed: %s %s" % (status, body))
        users[name] = body

    status, edition = request("POST", "/api/collections/edition/records", su,
                              data={"number": 1, "date": "2026-01-01 00:00:00.000Z"},
                              files={"pdf": ("edition1.pdf", PDF)})
    if status != 200:
        raise RuntimeError("edition creation failed: %s %s" % (status, edition))

    anecdotes = {}
    for key, user, published in (("alice_pub", "alice", True), ("alice_draft", "alice", False),
                                 ("bob_pub", "bob", True), ("bob_draft", "bob", False)):
        data = {"user": users[user]["id"], "text": "Anecdote " + key, "date": "2026-01-02 00:00:00.000Z",
                "published": str(published).lower()}
        if published:
            data["edition"] = edition["id"]
        status, body = request("POST", "/api/collections/anecdotes/records", su, data=data,
                               files={"image": (key + ".png", PNG)})
        if status != 200:
            raise RuntimeError("anecdote creation failed: %s %s" % (status, body))
        anecdotes[key] = body

    if upgrade_from:
        import_schema(su, schema_path, merge=True)
    return su, users, edition, anecdotes


# ---------------------------------------------------------------- checks

def run_checks(users, edition, anecdotes):
    a = anecdotes
    alice = auth("users", "alice", PASSWORD)
    bob = auth("users", "bob", PASSWORD)
    admin = auth("users", "admin", PASSWORD)
    alice_file_token = request("POST", "/api/files/token", alice)[1]["token"]
    drafts = {a["alice_draft"]["id"], a["bob_draft"]["id"]}

    print("\n--- Anonymous visitor")
    _, ids = list_ids("anecdotes_current")
    check("anonymous cannot list unpublished anecdotes (anecdotes_current)", not ids, "%d visible" % len(ids))
    _, ids = list_ids("anecdotes")
    check("anonymous cannot list anecdotes", not ids, "%d visible" % len(ids))
    _, ids = list_ids("editionStats")
    check("anonymous cannot list editionStats", not ids, "%d visible" % len(ids))
    _, ids = list_ids("users")
    check("anonymous cannot list users", not ids, "%d visible" % len(ids))
    for label, record, field in (("anecdote image", a["bob_draft"], "image"),
                                 ("avatar", users["bob"], "avatar"),
                                 ("edition PDF", edition, "pdf")):
        status, _ = request("GET", file_url(record, field), raw=True)
        check("anonymous cannot download %s by URL" % label, status != 200, "HTTP %d" % status)
    status, _ = request("GET", file_url(a["bob_draft"], "image", thumb="1000x1000f"), raw=True)
    check("anonymous cannot download image thumbnail", status != 200, "HTTP %d" % status)

    print("\n--- Family member (alice)")
    _, ids = list_ids("anecdotes", alice)
    expected = {a["alice_pub"]["id"], a["alice_draft"]["id"], a["bob_pub"]["id"]}
    check("member sees published + own drafts only", ids == expected,
          "bob's draft visible" if a["bob_draft"]["id"] in ids else "")
    status, _ = request("GET", "/api/collections/anecdotes/records/" + a["bob_draft"]["id"], alice)
    check("member cannot view another member's draft", status == 404, "HTTP %d" % status)
    _, ids = list_ids("anecdotes_current", alice)
    check("member cannot list anecdotes_current", not (ids & drafts), "%d visible" % len(ids))
    _, ids = list_ids("edition", alice, "&expand=editionStats_via_edition")
    check("member can list editions", edition["id"] in ids)
    _, body = request("GET", "/api/collections/edition/records?expand=editionStats_via_edition", alice)
    stats = (body["items"][0].get("expand") or {}).get("editionStats_via_edition")
    check("member sees edition stats through expand", bool(stats))
    _, ids = list_ids("users", alice)
    check("member can list family members", len(ids) == 3)

    status, _ = request("GET", file_url(a["alice_pub"], "image", alice_file_token), raw=True)
    check("member downloads image with file token", status == 200, "HTTP %d" % status)
    status, _ = request("GET", file_url(a["alice_pub"], "image", alice_file_token, "1000x1000f"), raw=True)
    check("member downloads thumbnail with file token", status == 200, "HTTP %d" % status)
    status, _ = request("GET", file_url(users["bob"], "avatar", alice_file_token, "200x200"), raw=True)
    check("member downloads avatar with file token", status == 200, "HTTP %d" % status)
    status, _ = request("GET", file_url(edition, "pdf", alice_file_token), raw=True)
    check("member downloads edition PDF with file token", status == 200, "HTTP %d" % status)

    # Same request as PocketbaseService.createAnecdote()
    status, created = request("POST", "/api/collections/anecdotes/records", alice, data={
        "user": users["alice"]["id"], "text": "new", "date": "2026-02-01 00:00:00.000",
        "published": "false"}, files={"image": ("new.png", PNG)})
    check("member creates an anecdote like the app does", status == 200, "HTTP %d" % status)
    status, _ = request("POST", "/api/collections/anecdotes/records", alice, data={
        "user": users["alice"]["id"], "text": "new", "date": "2026-02-01 00:00:00.000Z",
        "published": "true"}, files={"image": ("new.png", PNG)})
    check("member cannot create an already published anecdote", status != 200, "HTTP %d" % status)
    status, _ = request("POST", "/api/collections/anecdotes/records", alice, data={
        "user": users["bob"]["id"], "text": "spoof", "date": "2026-02-01 00:00:00.000Z",
        "published": "false"}, files={"image": ("new.png", PNG)})
    check("member cannot create an anecdote in another member's name", status != 200, "HTTP %d" % status)
    status, _ = request("POST", "/api/collections/anecdotes/records", alice, data={
        "user": users["alice"]["id"], "text": "html", "date": "2026-02-01 00:00:00.000Z",
        "published": "false"}, files={"image": ("evil.html", HTML)})
    check("member cannot upload an HTML file as image", status != 200, "HTTP %d" % status)

    # Same request as PocketbaseService.updateAnecdote()
    status, _ = request("PATCH", "/api/collections/anecdotes/records/" + a["alice_draft"]["id"], alice, data={
        "user": users["alice"]["id"], "text": "edited", "date": "2026-01-03 00:00:00.000"}, files={})
    check("member edits own draft like the app does", status == 200, "HTTP %d" % status)
    status, _ = request("PATCH", "/api/collections/anecdotes/records/" + a["bob_draft"]["id"], alice,
                        data={"text": "hacked"})
    check("member cannot edit another member's draft", status != 200, "HTTP %d" % status)
    status, _ = request("PATCH", "/api/collections/anecdotes/records/" + a["bob_pub"]["id"], alice,
                        data={"text": "hacked"})
    check("member cannot edit another member's published anecdote", status != 200, "HTTP %d" % status)
    status, _ = request("PATCH", "/api/collections/anecdotes/records/" + a["alice_draft"]["id"], alice,
                        data={"published": True})
    check("member cannot publish own draft", status != 200, "HTTP %d" % status)
    status, _ = request("PATCH", "/api/collections/anecdotes/records/" + a["alice_draft"]["id"], alice,
                        data={"user": users["bob"]["id"]})
    check("member cannot give own draft to another member", status != 200, "HTTP %d" % status)
    status, _ = request("PATCH", "/api/collections/anecdotes/records/" + a["alice_pub"]["id"], alice,
                        data={"text": "rewrite history"})
    check("member cannot edit own published anecdote", status != 200, "HTTP %d" % status)
    status, _ = request("PATCH", "/api/collections/users/records/" + users["alice"]["id"], alice,
                        data={"priviliged": True})
    check("member cannot make herself admin", status != 200, "HTTP %d" % status)
    status, _ = request("DELETE", "/api/collections/anecdotes/records/" + a["bob_draft"]["id"], alice)
    check("member cannot delete another member's draft", status != 204, "HTTP %d" % status)
    status, _ = request("DELETE", "/api/collections/anecdotes/records/" + a["alice_pub"]["id"], alice)
    check("member cannot delete own published anecdote", status != 204, "HTTP %d" % status)
    if created and "id" in created:
        status, _ = request("DELETE", "/api/collections/anecdotes/records/" + created["id"], alice)
        check("member deletes own draft (app delete button)", status == 204, "HTTP %d" % status)

    print("\n--- Admin (priviliged user)")
    _, ids = list_ids("anecdotes_current", admin)
    check("admin lists all unpublished anecdotes", drafts <= ids)
    _, ids = list_ids("anecdotes", admin, "&filter=" + urllib.parse.quote("published = false"))
    check("admin lists all drafts in anecdotes", drafts <= ids)
    # Same body as PocketbaseService.publishAnecdote() (Anecdote.toJson())
    draft = a["bob_draft"]
    status, body = request("PATCH", "/api/collections/anecdotes/records/" + draft["id"], admin, data={
        "id": draft["id"], "created": draft["created"], "updated": draft["updated"],
        "collectionId": draft["collectionId"], "collectionName": draft["collectionName"],
        "user": draft["user"], "date": draft["date"], "text": draft["text"], "image": draft["image"],
        "published": "true", "edition": edition["id"]})
    check("admin publishes a member's anecdote like the app does",
          status == 200 and body.get("published") is True, "HTTP %d" % status)
    status, _ = request("DELETE", "/api/collections/anecdotes/records/" + a["alice_pub"]["id"], admin)
    check("admin deletes any anecdote", status == 204, "HTTP %d" % status)

    print("\n--- Superuser endpoints")
    status, _ = request("POST", "/api/collections/users/records", alice, data={
        "username": "intruder", "password": PASSWORD, "passwordConfirm": PASSWORD})
    check("member cannot create accounts", status != 200, "HTTP %d" % status)
    status, _ = request("POST", "/api/collections/users/records", None, data={
        "username": "intruder", "password": PASSWORD, "passwordConfirm": PASSWORD})
    check("public sign-up is closed", status != 200, "HTTP %d" % status)
    del bob


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pocketbase", required=True, help="path to the pocketbase binary")
    parser.add_argument("--schema", default=os.path.join(os.path.dirname(__file__), "..", "..", "pocketbase",
                                                         "pb_schema.json"))
    parser.add_argument("--upgrade-from", help="schema of an existing instance: seed data with it, "
                                               "then merge-import --schema on top (upgrade path)")
    args = parser.parse_args()

    data_dir = tempfile.mkdtemp(prefix="pb_test_")
    proc = start_pocketbase(args.pocketbase, data_dir)
    try:
        _, users, edition, anecdotes = seed(args.schema, args.upgrade_from)
        run_checks(users, edition, anecdotes)
    finally:
        proc.terminate()
        proc.wait()
        shutil.rmtree(data_dir, ignore_errors=True)

    failed = [r for r in results if not r[1]]
    print("\n%d checks, %d passed, %d failed" % (len(results), len(results) - len(failed), len(failed)))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
