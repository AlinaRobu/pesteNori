import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:peste_nori/globals.dart';

typedef OfflineMapChoice = ({OfflineRegion? region, bool downloadNew});
typedef _SavedMap = ({OfflineRegion region, OfflineRegionStatus? status});

enum _OfflineMapAction { rename, delete }

Future<String?> showOfflineMapTitleDialog(
  BuildContext context, {
  required String initialTitle,
  bool renaming = false,
}) {
  final formKey = GlobalKey<FormState>();
  var title = initialTitle;
  return showDialog<String>(
    context: context,
    builder: (context) {
      void submit() {
        if (formKey.currentState!.validate()) {
          Navigator.pop(context, title.trim());
        }
      }

      return AlertDialog(
        title: Text(renaming ? translations.renameOfflineMap : translations.nameOfflineMap),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: initialTitle,
            decoration: InputDecoration(
              labelText: renaming ? translations.offlineMapTitle : translations.optionalOfflineMapTitle,
            ),
            onChanged: (value) => title = value,
            onFieldSubmitted: (_) => submit(),
            validator: (value) => renaming && value?.trim().isNotEmpty != true
                ? translations.enterOfflineMapTitle
                : null,
            maxLength: 80,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translations.cancel),
          ),
          FilledButton(
            onPressed: submit,
            child: Text(renaming ? translations.save : translations.download),
          ),
        ],
      );
    },
  );
}

class SavedOfflineMapsSheet extends StatefulWidget {
  const SavedOfflineMapsSheet({super.key});

  @override
  State<SavedOfflineMapsSheet> createState() => _SavedOfflineMapsSheetState();
}

class _SavedOfflineMapsSheetState extends State<SavedOfflineMapsSheet> {
  late Future<List<_SavedMap>> _areas = _loadAreas();
  bool _updatingArea = false;
  String? _updateError;

  Future<List<_SavedMap>> _loadAreas() async {
    final regions = (await getListOfRegions()).toList();
    regions.sort((a, b) => b.id.compareTo(a.id));
    return Future.wait(
      regions.map((region) async {
        OfflineRegionStatus? status;
        try {
          status = await getOfflineRegionStatus(region.id);
        } catch (error) {
          debugPrint('Could not read offline area status: $error');
        }
        return (region: region, status: status);
      }),
    );
  }

  String _name(OfflineRegion region) {
    final name = region.metadata['name']?.toString().trim();
    return name == null || name.isEmpty ? translations.offlineAreaNumber(region.id.toString()) : name;
  }

  Future<void> _rename(OfflineRegion region) async {
    final title = await showOfflineMapTitleDialog(
      context,
      initialTitle: _name(region),
      renaming: true,
    );
    if (!mounted || title == null || title == _name(region)) return;

    await _updateArea(() async {
      await updateOfflineRegionMetadata(region.id, {
        ...region.metadata,
        'name': title,
      });
    }, translations.offlineRenameError);
  }

  String _description(OfflineRegionStatus? status) {
    if (status == null) return translations.downloadStatusUnavailable;
    final bytes = status.completedResourceSize;
    final size = bytes >= 1000000
        ? translations.fileSizeMb((bytes / 1000000).toStringAsFixed(1))
        : translations.fileSizeKb((bytes / 1000).toStringAsFixed(0));
    return '${status.isComplete ? translations.readyOffline : translations.downloadIncomplete} · $size';
  }

  Future<void> _delete(OfflineRegion region) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translations.deleteOfflineMapQuestion),
        content: Text(translations.removeOfflineMap(_name(region))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translations.delete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    await _updateArea(
      () => deleteOfflineRegion(region.id),
      translations.offlineDeleteError,
    );
  }

  Future<void> _updateArea(
    Future<void> Function() update,
    String errorMessage,
  ) async {
    setState(() {
      _updatingArea = true;
      _updateError = null;
    });
    try {
      await update();
      if (mounted) {
        setState(() {
          _areas = _loadAreas();
        });
      }
    } catch (error) {
      debugPrint('Could not update offline map: $error');
      if (mounted) {
        setState(() => _updateError = errorMessage);
      }
    } finally {
      if (mounted) setState(() => _updatingArea = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.72,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                translations.savedOfflineMaps,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            if (_updateError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_updateError!),
              ),
            Expanded(
              child: FutureBuilder<List<_SavedMap>>(
                future: _areas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _areas = _loadAreas();
                          });
                        },
                        child: Text(translations.savedMapsLoadError),
                      ),
                    );
                  }
                  final areas = snapshot.data!;
                  if (areas.isEmpty) {
                    return Center(
                      child: Text(translations.noOfflineMaps),
                    );
                  }
                  return ListView.builder(
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      return ListTile(
                        leading: const Icon(Icons.map_outlined),
                        title: Text(_name(area.region)),
                        subtitle: Text(_description(area.status)),
                        onTap: _updatingArea
                            ? null
                            : () => Navigator.pop<OfflineMapChoice>(context, (
                                region: area.region,
                                downloadNew: false,
                              )),
                        trailing: PopupMenuButton<_OfflineMapAction>(
                          tooltip: translations.offlineMapOptions,
                          enabled: !_updatingArea,
                          onSelected: (action) {
                            switch (action) {
                              case _OfflineMapAction.rename:
                                _rename(area.region);
                              case _OfflineMapAction.delete:
                                _delete(area.region);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: _OfflineMapAction.rename,
                              child: Text(translations.rename),
                            ),
                            PopupMenuItem(
                              value: _OfflineMapAction.delete,
                              child: Text(translations.delete),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton.icon(
                onPressed: _updatingArea
                    ? null
                    : () => Navigator.pop<OfflineMapChoice>(context, (
                        region: null,
                        downloadNew: true,
                      )),
                icon: const Icon(Icons.download),
                label: Text(translations.downloadNewArea),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
