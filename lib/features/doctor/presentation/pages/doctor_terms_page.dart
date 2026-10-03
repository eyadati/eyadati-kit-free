import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';

class DoctorTermsPage extends StatelessWidget {
  const DoctorTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Conditions d'utilisation",
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('1. Objet'),
            _bodyText(
              'Les présentes conditions d\'utilisation régissent l\'accès et l\'utilisation '
              'de la plateforme Eyadati, une solution SaaS de gestion de rendez-vous médicaux '
              'destinée aux professionnels de santé et à leurs patients.',
            ),
            _sectionTitle('2. Définitions'),
            _bodyText(
              '• "Plateforme" : l\'application web Eyadati et ses services associés\n'
              '• "Médecin" : professionnel de santé utilisateur de la plateforme\n'
              '• "Patient" : personne physique prenant rendez-vous via la plateforme\n'
              '• "Compte" : espace personnel du médecin sur la plateforme',
            ),
            _sectionTitle('3. Inscription et compte'),
            _bodyText(
              'L\'inscription est réservée aux professionnels de santé habilités. '
              'Le médecin s\'engage à fournir des informations exactes et à tenir '
              'son compte à jour. Le compte est personnel et non cessible.\n\n'
              'Le médecin est responsable de la confidentialité de ses identifiants '
              'de connexion. Toute activité réalisée depuis son compte est réputée '
              'être effectuée par lui-même.',
            ),
            _sectionTitle('4. Services'),
            _bodyText(
              'Eyadati propose aux médecins :\n\n'
              '• La gestion du calendrier de rendez-vous\n'
              '• La notification des patients par e-mail\n'
              '• Le suivi des consultations\n'
              '• La gestion des patients\n'
              '• Les statistiques d\'activité',
            ),
            _sectionTitle('5. Obligations du médecin'),
            _bodyText(
              'Le médecin s\'engage à :\n\n'
              '• Respecter le secret médical et la confidentialité des données patients\n'
              '• Utiliser la plateforme conformément à la réglementation applicable\n'
              '• Ne pas détourner les fonctionnalités à des fins frauduleuses\n'
              '• Respecter les droits des patients concernant leurs données',
            ),
            _sectionTitle('6. Accès à la plateforme'),
            _bodyText(
              'L\'accès à la plateforme dépend des fonctionnalités incluses dans '
              'la version utilisée. Le médecin peut interrompre l\'utilisation de '
              'son compte à tout moment.',
            ),
            _sectionTitle('7. Propriété intellectuelle'),
            _bodyText(
              'La plateforme Eyadati, son code source, son design, ses marques et '
              'son contenu sont la propriété exclusive d\'Eyadati. Aucun droit de '
              'propriété intellectuelle n\'est transféré au médecin, qui bénéficie '
              'uniquement d\'une licence d\'utilisation non exclusive et non cessible.',
            ),
            _sectionTitle('8. Responsabilité'),
            _bodyText(
              'Eyadati s\'engage à mettre en œuvre tous les moyens raisonnables '
              'pour assurer la disponibilité et le bon fonctionnement de la plateforme. '
              'Cependant, Eyadati ne saurait être tenu responsable :\n\n'
              '• Des interruptions liées à la maintenance ou aux tiers\n'
              '• Des dommages indirects résultant de l\'utilisation du service\n'
              '• Du contenu échangé entre médecins et patients\n'
              '• Des décisions médicales prises sur la base des informations de la plateforme',
            ),
            _sectionTitle('9. Suspension et résiliation'),
            _bodyText(
              'Eyadati peut suspendre ou résilier un compte en cas de :\n\n'
              '• Violation grave des présentes conditions\n'
              '• Comportement frauduleux ou illicite\n'
              '• Inactivité prolongée (plus de 12 mois)\n\n'
              'Le médecin sera informé préalablement, sauf urgence.',
            ),
            _sectionTitle('10. Modification des conditions'),
            _bodyText(
              'Eyadati se réserve le droit de modifier les présentes conditions '
              'à tout moment. Les médecins seront informés des modifications '
              'significatives par e-mail ou via la plateforme. L\'utilisation '
              'continue du service après les modifications vaut acceptation.',
            ),
            _sectionTitle('11. Droit applicable'),
            _bodyText(
              'Les présentes conditions sont régies par le droit français. '
              'Tout litige relatif à leur interprétation ou exécution relève '
              'de la compétence des tribunaux français.',
            ),
            _sectionTitle('12. Contact'),
            _bodyText(
              'Pour toute question relative aux conditions d\'utilisation :\n\n'
              '• Par e-mail : support@YOUR_APP.example.com\n'
              '• Depuis l\'application : section Aide et support\n\n'
              'Dernière mise à jour : juin 2026',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        height: 1.6,
        color: AppColors.textSecondary,
      ),
    );
  }
}
