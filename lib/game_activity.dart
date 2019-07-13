import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/board_square.dart';


class GameActivity extends StatefulWidget {
  @override
  _GameActivityState createState() => _GameActivityState();
}


class _GameActivityState extends State<GameActivity> {
  // row and column count of the board
  int rowCount = 18;
  int columnCount = 10;

  // the grid of squares
  List<List<BoardSquare>> board;

  // "opened" refers to being clicked already
  List<bool> openedSquares;

  // a flagged square is a square a user has added a flag on by long pressing
  List<bool> flaggedSquares;

  // probability that a square will be a bomb
  int bombProbability = 3;
  int maxProbability = 15;

  int bombCount = 0;
  int squaresLeft;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.grey,
            height: 60.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _initializeGame();
                  },
                  child: CircleAvatar(
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    backgroundColor: Colors.yellowAccent,
                  ),
                )
              ],
            ),
          ),
          // the grid of squares
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
            ),
            itemBuilder: (context, position) {
              // get row and column number of square
              int rowNumber = (position / columnCount).floor();
              int columnNumber = (position % columnCount);

              Image image;

              if (openedSquares[position] == false) {
                if (flaggedSquares[position] == true) {
                  image = getImage(ImageType.flagged);
                } else {
                  image = getImage(ImageType.facingDown);
                }
              } else {
                if (board[rowNumber][columnNumber].hasBomb) {
                  image = getImage(ImageType.bomb);
                } else {
                  image = getImage(
                    getImageTypeFromNumber(board[rowNumber][columnNumber].bombsAround),
                  );
                }
              }

              return InkWell(
                // opens square
                onTap: () {
                  if (board[rowNumber][columnNumber].hasBomb) {
                    _handleGameOver();
                  }
                  if (board[rowNumber][columnNumber].bombsAround == 0) {
                    _handleTap(rowNumber, columnNumber);
                  } else {
                    setState(() {
                      openedSquares[position] = true;
                      squaresLeft = squaresLeft - 1;
                    });
                  }

                  if (squaresLeft <= bombCount) {
                    _handleWin();
                  }
                },

                // flags square
                onLongPress: () {
                  if (openedSquares[position] == false) {
                    setState(() {
                      flaggedSquares[position] = true;
                    });
                  }
                },
                splashColor: Colors.grey,
                child: Container(
                  color: Colors.grey,
                  child: image,
                ),
              );
            },
            itemCount: rowCount * columnCount;
          ),
        ],
      ),
    );
  }


  // initialises all lists
  void _initializeGame() {
    // initialise all squares to having no bombs
    board = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return BoardSquare();
      });
    });

    // initialize list to store which squares have been opened
    openedSquares = List.generate(rowCount * columnCount, (i) {
      return false;
    });

    flaggedSquares = List.generate(rowCount * columnCount, (i) {
      return false;
    });
    
    // Resets bomb count
    bombCount = 0;
    squaresLeft = rowCount * columnCount;

    // generate randomly for each square
    Random random = new Random();
    for(int i = 0; i < rowCount; i++){
      for(int j = 0; j < columnCount; j++){
        int randomNumber = random.nextInt(maxProbability);
        if(randomNumber < bombProbability){
          board[i][j].hasBomb = true;
          // bombCount is avariable to store the number of bomb on the board
          bombCount++;
        }
      }
    }

    // check bombs around and assign numbers
    for(int i = 0; i  < rowCount; i++){
      for(int j = 0; j < columnCount; j++){
        if(i > 0 && j > 0){
          if(board[i-1][j].hasBomb){
            board[i][j].bombsAround++;
          }
        }

        if(i > 0){
          if(board[i-1][j].hasBomb){
            board[i][j].bombsAround++;
          }
        }

        if(i > 0 && j < columnCount - 1){
          if(board[i-1][j+1].hasBomb){
            board[i][j].bombsAround++;
          }
        }

        if(j > 0){
          if(board[i][j+1].hasBomb){
            board[i][j].bombsAround++;
          }
        }

        if(j < columnCount - 1){
          if(board[i][j+1].hasBomb){
            board[i][j].bombsAround++;
          }
        }

        if(i < rowCount - 1 && j > 0){
          if(board[i+1][j-1].hasBomb){
            board[i][j].bombsAround++;
          }
        }

        if(i < rowCount - 1 && j < columnCount - 1){
          if(board[i+1][j+1].hasBomb){
            board[i][j].bombsAround++;
          }
        }
      }
    }

    setState(() {});
  }



  


  // this function opens other squares around the target square which don't have any bombs around them.
  // we use a recursive function which stops at squares which have a non zero number of bombs around them.
  void _handleTap(int i, int j) {
    
    int position = (i * columnCount) + j;
    openedSquares[position] = true;
    squaresLeft = squaresLeft - 1;

    if (i > 0) {
      if (!board[i - 1][j].hasBomb && openedSquares[((i -1) * columnCount) + j] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i - 1, j);
        }
      }
    }

    if (j > 0) {
      if (!board[i][j - 1].hasBomb && openedSquares[(i * columnCount) + j - 1] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i, j - 1);
        }
      }
    }

    if (j < columnCount - 1) {
      if (!board[i][j + 1].hasBomb && openedSquares[(i * columnCount) + j + 1] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i, j + 1);
        }
      }
    }

    if (i < rowCount - 1) {
      if (!board[i + 1][j].hasBomb && openedSquares[((i + 1) * columnCount) + j] != true) {
        if (board[i][j].bombsAround == 0) {
          _handleTap(i + 1, j);
        }
      }
    }
  }
}

