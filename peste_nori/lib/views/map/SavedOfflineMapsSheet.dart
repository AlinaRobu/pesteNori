import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

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
        title: Text(renaming ? 'Rename offline map' : 'Name your offline map'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: initialTitle,
            decoration: InputDecoration(
              labelText: renaming ? 'Title' : 'Title (optional)',
            ),
            onChanged: (value) => title = value,
            onFieldSubmitted: (_) => submit(),
            validator: (value) => renaming && value?.trim().isNotEmpty != true
                ? 'Enter a title'
                : null,
            maxLength: 80,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: submit,
            child: Text(renaming ? 'Save' : 'Download'),
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
    return name == null || name.isEmpty ? 'Offline area ${region.id}' : name;
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
    }, 'Could not rename this map. Try again.');
  }

  String _description(OfflineRegionStatus? status) {
    if (status == null) return 'Download status unavailable';
    final bytes = status.completedResourceSize;
    final size = bytes >= 1000000
        ? '${(bytes / 1000000).toStringAsFixed(1)} MB'
        : '${(bytes / 1000).toStringAsFixed(0)} KB';
    return '${status.isComplete ? 'Ready offline' : 'Download incomplete'} · $size';
  }

  Future<void> _delete(OfflineRegion region) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete offline map?'),
        content: Text('Remove “${_name(region)}” from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    await _updateArea(
      () => deleteOfflineRegion(region.id),
      'Could not delete this map. Try again.',
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
                'Saved offline maps',
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
                        child: const Text('Could not load saved maps. Retry'),
                      ),
                    );
                  }
                  final areas = snapshot.data!;
                  if (areas.isEmpty) {
                    return const Center(
                      child: Text('No offline maps saved yet'),
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
                          tooltip: 'Offline map options',
                          enabled: !_updatingArea,
                          onSelected: (action) {
                            switch (action) {
                              case _OfflineMapAction.rename:
                                _rename(area.region);
                              case _OfflineMapAction.delete:
                                _delete(area.region);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: _OfflineMapAction.rename,
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: _OfflineMapAction.delete,
                              child: Text('Delete'),
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
                label: const Text('Download new area'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
