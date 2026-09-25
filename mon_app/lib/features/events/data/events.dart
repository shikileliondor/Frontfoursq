import '../../../core/constants/app_assets.dart';
import '../domain/models/event.dart';

const fallbackEvents = [
  Event(
    id: 'congres-jeunesse',
    title: 'Congres Jeunesse Foursquare 2025',
    location: 'Palais de la Culture',
    date: '18 Oct 2025',
    time: '08h00',
    scopeLabel: 'JEUNESSE',
    imagePath: AppAssets.youthEvent,
  ),
  Event(
    id: 'nuit-priere',
    title: 'Nuit de Prieres Nationale',
    location: 'Cocody, Abidjan',
    date: '26 Sep 2025',
    time: '20h00',
    scopeLabel: 'NATIONAL',
    imagePath: AppAssets.events,
  ),
  Event(
    id: 'camp-biblique',
    title: 'Camp de Vacances Bibliques',
    location: 'Daloa',
    date: '04 Oct 2025',
    time: '09h00',
    scopeLabel: 'FORMATION',
    imagePath: AppAssets.community,
  ),
];
