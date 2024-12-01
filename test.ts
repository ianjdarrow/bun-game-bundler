import { gameWindow } from "./src/bun/windowManagement";

async function main() {
  await gameWindow.open("My Game");

  // Your game logic here
  // The window will automatically close when the user clicks the close button
  // or when your program exits
}

main().catch(console.error);
