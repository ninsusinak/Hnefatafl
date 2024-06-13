Hnefatafl Game

Overview

This project is a simple implementation of the Hnefatafl board game using the Godot game engine. The game follows the rules of Hnefatafl played on a 9x9 board.
Rules

Hnefatafl is an ancient Norse strategy board game. Here are the rules specific to this implementation:

    Board Size: 9x9 grid.
    Pieces:
        One King piece (Defender), starting in the center (4, 4).
        Eight Attackers, placed around the King in a symmetric pattern.
    Movement:
        The King (Defender) moves like a chess King – one square in any direction.
        Attackers move like chess Rooks – any number of squares vertically or horizontally.
    Objective:
        The Defender (King) aims to escape to any edge of the board.
        The Attackers aim to capture the Defender by surrounding it on all four sides.
    Capture:
        Attackers capture the King by surrounding it on two opposite sides (vertically or horizontally).

Controls

    Mouse Click: Select and move pieces.
    Turns: Players take turns moving pieces according to the rules.

Features

    Visual representation of the game board.
    Interactive piece movement based on Hnefatafl rules.
    Sound effects for piece selection, movement, and victory.
    Victory screen upon achieving game objectives.

Getting Started

To run the game locally:

    Clone this repository:

    bash

    git clone https://github.com/your-username/hnefatafl-game.git
    cd hnefatafl-game

    Open the project in Godot Engine.

    Run the project from Godot.

Future Improvements

    Implement an AI opponent for single-player mode.
    Add multiplayer functionality.
    Enhance graphics and animations.

Contributing

Contributions are welcome! Please fork the repository and create a pull request for any new features, improvements, or bug fixes.
License

This project is licensed under the GPL3.0 License - see the LICENSE file for details.
Acknowledgments

    Inspired by the ancient game of Hnefatafl.
    Built using the Godot game engine.
