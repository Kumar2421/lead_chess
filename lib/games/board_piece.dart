import 'package:flutter/material.dart';
import 'tile.dart';

import 'package:get_it/get_it.dart';
import 'game_logic.dart';

final logic = GetIt.instance<GameLogic>();


class BoardPiece extends StatelessWidget {
  const BoardPiece({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the screen size
        var screenSize = MediaQuery.of(context).size;
        bool isTablet = screenSize.shortestSide >= 600;

        // Set the tile size based on the device type
        double tileSize;
        if (isTablet) {
          tileSize = (constraints.maxWidth < constraints.maxHeight)
              ? constraints.maxWidth / 10
              : constraints.maxHeight / 10;
        } else {
          tileSize = (constraints.maxWidth < constraints.maxHeight)
              ? constraints.maxWidth / 8
              : constraints.maxHeight / 8;
        }

        return Center(
          child: SizedBox(
            width: tileSize * 8,
            height: tileSize * 8,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (int rank = 0; rank < 8; ++rank)
                  TableRow(
                    children: [
                      for (int file = 0; file < 8; ++file)
                        TableCell(
                          child: SizedBox(
                            width: tileSize,
                            height: tileSize,
                            child: Tile(
                              index: logic.args.asBlack
                                  ? logic.boardIndex(rank, 7 - file)
                                  : logic.boardIndex(7 - rank, file),
                            ),
                          ),
                        )
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}