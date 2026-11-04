import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

@RoutePage()
class EntryPage extends ConsumerStatefulWidget {
  final String id;

  const EntryPage({super.key, @PathParam("id") required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(widget.id)));
  }
}
