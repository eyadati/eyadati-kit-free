/// Region configuration for the kit.
///
/// The default list is inherited from the upstream (Algeria-only) product.
/// Replace it with your own region's cities, or empty the list and switch
/// the corresponding UI fields to free text input.
class AppRegions {
  AppRegions._();

  static const List<String> cities = [
    'Adrar', 'Ain Defla', 'Ain Temouchent', 'Alger',
    'Annaba', 'Batna', 'Bechar', 'Bejaia',
    'Biskra', 'Blida', 'Bordj Bou Arreridj', 'Bouira',
    'Boumerdes', 'Chlef', 'Constantine', 'Djelfa',
    'El Bayadh', 'El Oued', 'El Tarf', 'Ghardaia',
    'Guelma', 'Illizi', 'Jijel', 'Khenchela',
    'Laghouat', 'Mascara', 'Medea', 'Mila',
    'Mostaganem', 'Msila', 'Naama', 'Oran',
    'Ouargla', 'Oum El Bouaghi', 'Relizane', 'Saida',
    'Setif', 'Sidi Bel Abbes', 'Skikda', 'Souk Ahras',
    'Tamanghasset', 'Tebessa', 'Tiaret', 'Tindouf',
    'Tipaza', 'Tissemsilt', 'Tizi Ouzou', 'Tlemcen',
  ];
}
