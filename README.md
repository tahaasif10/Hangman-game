# Hangman Game in x86 Assembly

This project implements a fully functional **Hangman game** using x86 Assembly language for DOS. It includes VGA graphics to draw the hangman figure progressively as the player makes incorrect guesses.

## 📜 Overview

- **Word Selection**: Randomly picks a word from a predefined list.
- **Gameplay**: Displays underscores for unguessed letters and updates as the player guesses letters.
- **Graphics**: Draws hangman parts (gallows, head, body, limbs) using VGA mode as the player makes wrong guesses.
- **Win/Lose Conditions**:
  - Win by guessing the word before using all guesses.
  - Lose if all guesses are used before completing the word.

## 🚀 Features

✅ Runs in DOS real mode with 16-bit x86 instructions  
✅ Uses BIOS and DOS interrupts for I/O  
✅ Simple randomization for word selection  
✅ ASCII-based messages with colored VGA graphics  
✅ Hangman drawing updates as you make incorrect guesses

## 🛠️ Requirements

- DOS environment or DOS emulator (e.g., DOSBox)
- 16-bit x86 assembler (e.g., TASM, MASM, or NASM with `.MODEL SMALL` support)
- VGA-compatible graphics (DOSBox works perfectly)

#### Enjoy the Game!
