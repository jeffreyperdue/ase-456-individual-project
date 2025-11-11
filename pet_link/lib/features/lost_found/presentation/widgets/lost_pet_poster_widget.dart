import 'package:flutter/material.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;

/// Widget that renders a lost pet poster.
/// This widget is designed to be converted to an image using the screenshot package.
class LostPetPosterWidget extends StatelessWidget {
  final Pet pet;
  final app_user.User owner;
  final String? lastSeenLocation;
  final String? notes;
  final DateTime lostDate;

  const LostPetPosterWidget({
    super.key,
    required this.pet,
    required this.owner,
    this.lastSeenLocation,
    this.notes,
    required this.lostDate,
  });

  @override
  Widget build(BuildContext context) {
    // Poster dimensions - optimized for sharing (4:3 aspect ratio)
    const posterWidth = 800.0;
    const posterHeight = 1000.0;

    return Container(
      width: posterWidth,
      height: posterHeight,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with "LOST" text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            color: Colors.red,
            child: const Text(
              'LOST',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pet photo
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 4),
            ),
            child: ClipOval(
              child: pet.photoUrl != null
                  ? Image.network(
                      pet.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),

          const SizedBox(height: 32),

          // Pet name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              pet.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pet species and breed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _getPetDescription(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Last seen location (if provided)
          if (lastSeenLocation != null && lastSeenLocation!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Last seen: $lastSeenLocation',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Lost date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Lost on: ${_formatDate(lostDate)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Notes (if provided)
          if (notes != null && notes!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notes!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Spacer(),

          // Contact information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.grey[200],
            child: Column(
              children: [
                const Text(
                  'If found, please contact:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (owner.displayName != null) ...[
                  Text(
                    owner.displayName!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  owner.email,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // App branding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.grey[300],
            child: const Text(
              'Petfolio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.pets,
          size: 200,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getPetDescription() {
    final parts = <String>[];
    parts.add(pet.species);
    if (pet.breed != null && pet.breed!.isNotEmpty) {
      parts.add(pet.breed!);
    }
    return parts.join(' • ');
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

