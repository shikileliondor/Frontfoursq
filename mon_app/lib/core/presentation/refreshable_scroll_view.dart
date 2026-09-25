import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Une liste que l'on recharge en tirant vers le bas.
///
/// Regroupe les deux reglages faciles a oublier :
///
/// - `AlwaysScrollableScrollPhysics`, sans quoi une page dont le contenu tient
///   dans l'ecran refuse le geste — c'est justement une page vide, ou en echec,
///   que l'on veut pouvoir recharger ;
/// - la couleur de l'indicateur, qui suit la charte au lieu du bleu Material.
///
/// `RefreshIndicator` garde son animation jusqu'a ce que `onRefresh` se termine :
/// le rappel doit donc attendre le chargement, pas seulement le declencher.
class RefreshableScrollView extends StatelessWidget {
  const RefreshableScrollView({
    required this.onRefresh,
    required this.slivers,
    super.key,
  });

  final Future<void> Function() onRefresh;

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.actionRed,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
