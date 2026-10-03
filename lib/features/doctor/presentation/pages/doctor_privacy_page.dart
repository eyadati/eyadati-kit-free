import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';

class DoctorPrivacyPage extends StatelessWidget {
  const DoctorPrivacyPage({super.key});

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
          'Politique de confidentialité',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('1. Responsable du traitement'),
            _bodyText(
              'Eyadati ("nous", "notre", "nos") est le responsable du traitement des données '
              'personnelles collectées via notre plateforme de gestion de rendez-vous médicaux.',
            ),
            _sectionTitle('2. Données collectées'),
            _bodyText(
              'Nous collectons les données suivantes :\n\n'
              '• Données d\'identification : nom, prénom, adresse e-mail, numéro de téléphone\n'
              '• Données professionnelles (pour les médecins) : spécialité, numéro d\'inscription, '
              'adresse du cabinet, horaires de travail\n'
              '• Données de connexion : adresse IP, type de navigateur, pages visitées\n'
              '• Données de rendez-vous : date, heure, type de consultation, notes',
            ),
            _sectionTitle('3. Finalités du traitement'),
            _bodyText(
              'Vos données sont traitées pour :\n\n'
              '• La gestion des rendez-vous médicaux\n'
              '• La communication entre médecins et patients\n'
              '• L\'envoi d\'e-mails transactionnels\n'
              '• L\'amélioration de nos services\n'
              '• Le respect de nos obligations légales',
            ),
            _sectionTitle('4. Base légale'),
            _bodyText(
              'Le traitement de vos données repose sur :\n\n'
              '• L\'exécution du contrat de service\n'
              '• Votre consentement (pour les cookies et notifications)\n'
              '• Notre intérêt légitime (amélioration du service)\n'
              '• Les obligations légales (facturation, archivage)',
            ),
            _sectionTitle('5. Durée de conservation'),
            _bodyText(
              'Nous conservons vos données :\n\n'
              '• Données de compte : pendant toute la durée de votre inscription\n'
              '• Données de rendez-vous : 5 ans après le dernier rendez-vous\n'
              '• Données de connexion : 1 an',
            ),
            _sectionTitle('6. Destinataires des données'),
            _bodyText(
              'Vos données peuvent être partagées avec :\n\n'
              '• Les prestataires techniques (hébergement Cloudflare, base de données Supabase)\n'
              '• Les autorités compétentes en cas d\'obligation légale\n\n'
              'Nous ne vendons jamais vos données personnelles à des tiers.',
            ),
            _sectionTitle('7. Cookies'),
            _bodyText(
              'Notre plateforme utilise des cookies essentiels au fonctionnement du service. '
              'Aucun cookie de pistage tiers n\'est utilisé sans votre consentement explicite. '
              'Vous pouvez configurer vos préférences de cookies à tout moment.',
            ),
            _sectionTitle('8. Vos droits'),
            _bodyText(
              'Conformément au RGPD, vous disposez des droits suivants :\n\n'
              '• Droit d\'accès : obtenir une copie de vos données\n'
              '• Droit de rectification : corriger vos données inexactes\n'
              '• Droit à l\'effacement : demander la suppression de vos données\n'
              '• Droit à la limitation : limiter le traitement de vos données\n'
              '• Droit à la portabilité : recevoir vos données dans un format structuré\n'
              '• Droit d\'opposition : vous opposer au traitement de vos données\n\n'
              'Pour exercer vos droits, contactez-nous à l\'adresse ci-dessous.',
            ),
            _sectionTitle('9. Sécurité'),
            _bodyText(
              'Nous mettons en œuvre des mesures techniques et organisationnelles appropriées '
              'pour protéger vos données contre tout accès non autorisé, modification, '
              'divulgation ou destruction. Ces mesures incluent le chiffrement des données, '
              'les contrôles d\'accès et la surveillance continue.',
            ),
            _sectionTitle('10. Contact'),
            _bodyText(
              'Pour toute question concernant cette politique de confidentialité ou pour '
              'exercer vos droits, vous pouvez nous contacter :\n\n'
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
