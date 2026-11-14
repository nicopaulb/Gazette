import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AddAnecdoteController.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddPostFragment extends StatefulWidget {
  @override
  State<AddPostFragment> createState() => _AddPostFragmentState();
}

class _AddPostFragmentState extends State<AddPostFragment> {
  final AddAnecdoteController _controller = Get.put(AddAnecdoteController());
  final ScrollController _scrollController = ScrollController();

  void _scrollToForm() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<AddAnecdoteController>(
      builder: (_) => Obx(() {
            final theme = Theme.of(context);
            final uploading = _controller.isUploading.value;
            final editing = _controller.openedAnecdote != null;
            final status = _controller.draftStatus.value;
            return Scaffold(
              backgroundColor: getScaffoldColor(),
              appBar: AppBar(
                backgroundColor: getScaffoldColor(),
                iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
                automaticallyImplyLeading: false,
                title: Text('Publier',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                centerTitle: true,
                actions: [
                  if (editing)
                    TextButton.icon(
                      onPressed: uploading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              await _controller.openAnecdote(-1);
                              if (mounted && _controller.openedAnecdote == null)
                                _scrollToForm();
                            },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Nouvelle'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColorPrimary),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
              body: SafeArea(
                  child: Center(
                      child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  key: const PageStorageKey('publish-form'),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (status != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                      status.startsWith('Brouillon non')
                                          ? Icons.warning_amber_rounded
                                          : Icons.save_outlined,
                                      size: 18,
                                      color: status.startsWith('Brouillon non')
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(status,
                                          style: theme.textTheme.bodySmall)),
                                  if (status.startsWith('Brouillon non'))
                                    TextButton(
                                        onPressed: uploading
                                            ? null
                                            : _controller.saveDraft,
                                        child: const Text('Réessayer')),
                                ]),
                          ),
                        if (_controller.actionError.value != null)
                          RecoveryMessage(
                              message: _controller.actionError.value!,
                              onRetry:
                                  uploading ? null : _controller.retryAction),
                        _PublishPanel(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                              Text(
                                  editing
                                      ? 'Modifier l’anecdote'
                                      : 'Nouvelle anecdote',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 16),
                              Form(
                                key: _controller.formKey,
                                child: TextFormField(
                                  controller: _controller.contentTextController,
                                  enabled: !uploading,
                                  minLines: 5,
                                  maxLines: 8,
                                  maxLength: 330,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(height: 1.5),
                                  validator: (value) => value == null ||
                                          value.trim().isEmpty
                                      ? 'Écrivez votre anecdote avant de l’envoyer.'
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'Anecdote (obligatoire)',
                                    hintText: 'Il était une fois…',
                                    alignLabelWithHint: true,
                                    filled: true,
                                    fillColor: getScaffoldColor(),
                                    contentPadding: const EdgeInsets.all(16),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ])),
                        const SizedBox(height: 16),
                        _photoPanel(context, uploading),
                        const SizedBox(height: 16),
                        Material(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            enabled: !uploading,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            leading: const Icon(Icons.calendar_month_outlined,
                                color: AppColorPrimary),
                            title: const Text('Date du souvenir',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(DateFormat.yMMMMd('fr_FR')
                                .format(_controller.selectedDate)),
                            trailing: const Icon(Icons.edit_calendar_outlined),
                            onTap: () => _controller.pickerDate(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: uploading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  if (editing) {
                                    _controller.sendUpdatedAnecdote();
                                  } else {
                                    _controller.sendNewAnecdote();
                                  }
                                },
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColorPrimary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16)),
                          icon: uploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      semanticsLabel: 'Envoi en cours'))
                              : Icon(
                                  editing ? Icons.check : Icons.send_outlined),
                          label: Text(uploading
                              ? 'Envoi en cours…'
                              : editing
                                  ? 'Enregistrer les modifications'
                                  : 'Envoyer l’anecdote'),
                        ),
                        if (editing)
                          Align(
                              alignment: Alignment.center,
                              child: TextButton.icon(
                                onPressed: uploading
                                    ? null
                                    : _controller.deleteAnecdote,
                                style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                    minimumSize: const Size(48, 48)),
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                label: const Text('Supprimer l’anecdote'),
                              )),
                        const SizedBox(height: 28),
                        Row(children: [
                          Expanded(
                              child: Text('Mes anecdotes envoyées',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700))),
                          IconButton(
                            tooltip: 'Actualiser mes anecdotes',
                            onPressed: uploading ||
                                    _controller.isLoadingSubmitted.value
                                ? null
                                : _controller.getSubmittedAnecdotes,
                            icon: const Icon(Icons.refresh),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        if (_controller.isLoadingSubmitted.value)
                          const LinearProgressIndicator(
                              semanticsLabel:
                                  'Chargement des anecdotes envoyées'),
                        if (_controller.submittedError.value != null)
                          RecoveryMessage(
                              message: _controller.submittedError.value!,
                              onRetry: uploading
                                  ? null
                                  : _controller.getSubmittedAnecdotes),
                        if (_controller.submittedAnecdotes.isEmpty &&
                            !_controller.isLoadingSubmitted.value &&
                            _controller.submittedError.value == null)
                          _PublishPanel(
                              child: Text(
                                  'Aucune anecdote envoyée pour le moment.',
                                  style: theme.textTheme.bodyMedium)),
                        for (final entry in _controller.submittedAnecdotes
                            .asMap()
                            .entries
                            .toList()
                            .reversed)
                          Padding(
                            key: ValueKey(entry.value.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                enabled: !uploading,
                                selected:
                                    _controller.isAnecdoteOpened(entry.key),
                                selectedTileColor:
                                    AppColorPrimary.withValues(alpha: 0.08),
                                selectedColor: theme.colorScheme.onSurface,
                                contentPadding: const EdgeInsets.all(12),
                                leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: entry.value
                                          .getResizedImage(150, 150, true),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(Icons.image_outlined)),
                                      errorWidget: (_, __, ___) =>
                                          const SizedBox(
                                              width: 56,
                                              height: 56,
                                              child: Icon(
                                                  Icons.broken_image_outlined)),
                                    )),
                                title: Text(entry.value.text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: entry.value.date == null
                                    ? null
                                    : Text(DateFormat.yMMMd('fr_FR')
                                        .format(entry.value.date!)),
                                trailing: _controller
                                        .isAnecdoteOpened(entry.key)
                                    ? const Icon(Icons.check_circle,
                                        color: AppColorPrimary)
                                    : const Icon(Icons.edit_outlined, size: 20),
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  await _controller.openAnecdote(entry.key);
                                  if (mounted &&
                                      _controller.openedAnecdote?.id ==
                                          entry.value.id) _scrollToForm();
                                },
                              ),
                            ),
                          ),
                      ]),
                ),
              ))),
            );
          }));

  Widget _photoPanel(BuildContext context, bool uploading) {
    final theme = Theme.of(context);
    final bytes = _controller.selectedImageBytes;
    final existingUrl = _controller.openedAnecdote?.imageUri ?? '';
    final hasPhoto = bytes != null || existingUrl.isNotEmpty;
    return _PublishPanel(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Photo (obligatoire)',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      if (hasPhoto) ...[
        ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: getScaffoldColor(),
              child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: bytes != null
                      ? Image.memory(bytes,
                          fit: BoxFit.contain,
                          semanticLabel: 'Aperçu de la photo sélectionnée')
                      : CachedNetworkImage(
                          imageUrl: existingUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 40)))),
            )),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 4, children: [
          OutlinedButton.icon(
              onPressed:
                  uploading ? null : () => _controller.pickerImage(context),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Changer la photo')),
          if (bytes != null)
            TextButton.icon(
                onPressed: uploading ? null : _controller.removeSelectedImage,
                icon: const Icon(Icons.close, size: 18),
                label: Text(_controller.openedAnecdote == null
                    ? 'Retirer'
                    : 'Annuler le remplacement')),
        ]),
      ] else
        OutlinedButton(
          onPressed: uploading ? null : () => _controller.pickerImage(context),
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: const Column(children: [
            Icon(Icons.add_photo_alternate_outlined, size: 36),
            SizedBox(height: 12),
            Text('Choisir une photo')
          ]),
        ),
      if (_controller.selectedImageError)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
              liveRegion: true,
              child: Text('Ajoutez une photo pour envoyer cette anecdote.',
                  style: TextStyle(color: theme.colorScheme.error))),
        ),
    ]));
  }
}

class _PublishPanel extends StatelessWidget {
  const _PublishPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24)),
        child: child,
      );
}
