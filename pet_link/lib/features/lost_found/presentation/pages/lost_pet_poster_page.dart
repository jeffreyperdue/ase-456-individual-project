import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import 'package:petfolio/features/lost_found/presentation/widgets/lost_pet_poster_widget.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';
import 'package:petfolio/features/lost_found/presentation/state/lost_found_provider.dart';

/// Page that displays the lost pet poster and allows sharing.
class LostPetPosterPage extends ConsumerStatefulWidget {
  final Pet pet;
  final app_user.User owner;
  final LostReport lostReport;

  const LostPetPosterPage({
    super.key,
    required this.pet,
    required this.owner,
    required this.lostReport,
  });

  @override
  ConsumerState<LostPetPosterPage> createState() => _LostPetPosterPageState();
}

class _LostPetPosterPageState extends ConsumerState<LostPetPosterPage> {
  final GlobalKey _posterKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Pet Poster'),
        actions: [
          if (!_isSharing)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePoster,
              tooltip: 'Share Poster',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Poster preview
            RepaintBoundary(
              key: _posterKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: LostPetPosterWidget(
                  pet: widget.pet,
                  owner: widget.owner,
                  lastSeenLocation: widget.lostReport.lastSeenLocation,
                  notes: widget.lostReport.notes,
                  lostDate: widget.lostReport.createdAt,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_isSharing)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    // Share button
                    FilledButton.icon(
                      onPressed: _sharePoster,
                      icon: const Icon(Icons.share),
                      label: const Text('Share Poster'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mark as Found button
                    OutlinedButton.icon(
                      onPressed: _markAsFound,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Found'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePoster() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // Wait for images to load if pet has a photo
      if (widget.pet.photoUrl != null) {
        await _waitForImageToLoad(widget.pet.photoUrl!);
      } else {
        // Still wait a bit for widget to render
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Wait one more frame to ensure everything is rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Get the RenderRepaintBoundary from the GlobalKey
      final RenderRepaintBoundary? boundary =
          _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to capture poster. Please try again.'),
            ),
          );
        }
        return;
      }

      // Convert the widget to an image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate poster image'),
            ),
          );
        }
        return;
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Upload to Firebase Storage if not already uploaded
      if (widget.lostReport.posterUrl == null) {
        final posterService = ref.read(posterGeneratorServiceProvider);
        try {
          final posterUrl = await posterService.uploadPoster(
            imageBytes: imageBytes,
            ownerId: widget.owner.id,
            petId: widget.pet.id,
          );

          // Update lost report with poster URL
          final repository = ref.read(lostReportRepositoryProvider);
          await repository.updateLostReport(
            widget.lostReport.id,
            {'posterUrl': posterUrl},
          );
        } catch (e) {
          // Continue with sharing even if upload fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Poster generated but upload failed: $e'),
              ),
            );
          }
        }
      }

      // Share the image
      final xFile = XFile.fromData(
        imageBytes,
        name: 'lost_pet_${widget.pet.name}_poster.png',
        mimeType: 'image/png',
      );

      await Share.shareXFiles(
        [xFile],
        text: 'Lost Pet: ${widget.pet.name}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing poster: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _markAsFound() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Found'),
        content: Text('Are you sure ${widget.pet.name} has been found?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Found'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final notifier = ref.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsFound(
          pet: widget.pet,
          lostReport: widget.lostReport,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.pet.name} has been marked as found!'),
            ),
          );
          Navigator.pop(context); // Go back to pet detail page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking pet as found: $e'),
            ),
          );
        }
      }
    }
  }

  /// Wait for a network image to load by resolving the ImageProvider.
  Future<void> _waitForImageToLoad(String imageUrl) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      final completer = Completer<void>();
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          imageStream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          // Image failed to load, but continue anyway (will show placeholder)
          if (!completer.isCompleted) {
            completer.complete();
          }
          imageStream.removeListener(listener);
        },
      );
      
      imageStream.addListener(listener);
      
      // Timeout after 3 seconds to prevent indefinite waiting
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          imageStream.removeListener(listener);
        },
      );
    } catch (e) {
      // If image loading check fails, continue anyway
      // The poster will show a placeholder if image doesn't load
    }
  }
}

