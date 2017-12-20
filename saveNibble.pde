import java.util.concurrent.ThreadLocalRandom;
import java.lang.Math;

import processing.sound.*;
SoundFile file;

//game vars
ArrayList<Row> grid;      // ArrayList of rows
int level;                // columns
int score;                // life/progress to next level
int fCount;               // frame number
int hintMode;             // default: 1 (2^i), easy: 2 (base 10 num), hard: 0 (no hints)
int speed;
int gameMode;             //define the gamestate. 0 and 1 is the intro. 2 is the game
boolean bossState;
boolean pause;            // boolean variable to pause the game

//assets
PFont single;
PImage img;
Button modeButton;
Button startButton;
Button playButton;

//Window Size
final int H = 50;
final int W = 50;
final int WIN_H = 400;
final int WIN_W = 400;

class Row {
    //variables
    private boolean[] bin;
    private int goal;

    //constructor
    public Row(int level) {
        bin = new boolean[level + 1];
        goal = ThreadLocalRandom.current().nextInt(1, (int)(java.lang.Math.pow(2, (level + 1)))); // random number between 1 and 2^(columnSize)-1
    }

    public boolean check() {
        int total = 0, curPower = 1;
        for (int i = 0; i < bin.length; i++) {
            if (bin[i]) {
                total += curPower;
            }
            curPower *= 2;
        }
        return total == goal;
    }

    public void flip(int pos) {
        bin[pos] = !bin[pos];
    }

    public void drawRow(int rowH) {
        textFont(single);
        stroke(66, 191, 244);
        for (int i = 0; i < bin.length; i++) {
            fill(0, 0, 0);
            rect(WIN_W - (i+1) * W, WIN_H - H*(rowH+1), W, H, 0, 15, 0, 15);
            fill(256, 256, 256);
            if (bin[i])
                text("1", WIN_W - W*(i+1), WIN_H - H*(rowH+1), W, H);
            else
                //text("1", WIN_W - W*(i+1), WIN_H - H*(rowH+1), W, H);
                text("0", WIN_W - W*(i+1), WIN_H - H*(rowH+1), W, H);
        }
        fill(0, 0, 0);
        stroke(196, 21, 21);
        rect(WIN_W, WIN_H - H * (rowH + 1), W*2, H, 0, 15, 0, 15);
        fill(256, 256, 256);
        text("" + goal, WIN_W, WIN_H - H*(rowH+1), W*2, H);
    }
}

void setup() {
    gameMode = 0;
    //fonts
    single = createFont("assets/binxchr.ttf", 50);
    //gui
    size(650, 450);
    textAlign(CENTER);
    background(0);
    strokeWeight(3);
    img = loadImage("assets/nibbler.png");
    smooth();
    modeButton = new Button("Mode", 415, 405, 80, 30);
    startButton = new Button("Start", 275, 370, 100, 50);
    playButton = new Button("Play", 540, 405, 80, 30);
}

void gameSetup() {
    level = 1;
    speed = 130;
    score = 0;
    hintMode = 1;
    bossState = false;
    grid = new ArrayList<Row>();
    grid.add(new Row(level));
    file = new SoundFile(this, sketchPath("")+"assets/soundtrack/inGame.mp3");
    file.loop();
}
void draw() {
    clear();
    if (gameMode == 0) {
        textFont(single);
        fill(255, 255, 255);
        textSize(80);
        gradient();
        textSize(25);
        text("Help! Nibbler got sucked into the computer.", 325, 100);
        text("You must get him out before the world collapses.", 325, 140);
        text("To protect Nibbler you must destroy the viruses.", 325, 180);
        text("To destroy the viruses you need to place 1’s and", 325, 220);
        text("0’s to make the indicated number on the right.", 325, 260);
        startButton.drawButton();
    } else if (gameMode == 2) {
        textFont(single);
        fill(255);
        textSize(60);
        text("Introduction", 325, 30);
        textSize(20);
        text("You must help nibbler escape the computer by combating", 320, 80);
        text("the incoming viruses. This is what a virus looks like:", 340, 100);
        textFont(single);
        fill(0);
        stroke(196, 21, 21);
        rect(390, 130, W*2, H, 0, 15, 0, 15);
        stroke(66, 191, 244);
        fill(255);
        text("7", 435, 150);
        for (int i = 0; i < 4; i++) {
            fill(0);
            rect(190 + (i * 50), 130, W, H, 0, 15, 0, 15);
            textSize(60);
            fill(255);
            text("7", 390, 130, W*2, H);
            if (i % 2 == 0) {
                text("0", 216 + (i * 50), 146);
            } else {
                text("1", 216 + (i * 50), 146);
            }
            textSize(24);
            text("2", 365 - (i * 50), 200);
            textSize(16);
            text(i, 375 - (i * 50), 195);
        }
        textSize(20);
        text("You can fight a virus by clicking the binary numbers in the", 330, 240);
        text("blue boxes to switch them between 0s and 1s. The binary", 330, 260);
        text("numbers must match the decimal number on the right in", 330, 280);
        text("the red box. Each digit of the binary number represents", 330, 300);
        text("a power of 2 as shown above. The zeros and ones", 330, 320);
        text("represent trues and falses for which ones to add.", 330, 340);

        text("So the above number is currently equal to:", 0, 385, 650, 20);
        text("2 + 2 or 4 + 1 = 5", 0, 405, 650, 20);
        textSize(10);
        text("2", 245, 410);
        text("0", 285, 410);
        textSize(20);
        text("Defeat the virus at the top of the screen to continue.", 0, 425, 650, 20);
    } else if (gameMode == 3) {
        textFont(single);
        fill(255);
        textSize(60);
        text("Rules", 325, 30);
        textSize(20);
        text("There will be a lot of viruses attacking you at once, you", 330, 80);
        text("must clear them out as fast as possible! When the binary", 330, 100);
        text("number equals the decimal number in the red box, the", 330, 120);
        text("row will disappear and the rows above it will drop down.", 330, 140);
        text("For each virus you destroy, you will earn a point", 0, 160, 650, 20);
        text("displayed by the green bar on the right of the screen.", 0, 180, 650, 20);
        text(" When you get 10 points you will face a virus swarm, 3", 0, 200, 650, 20);
        text("rows will instantly appear and rows will show up faster", 0, 220, 650, 20);
        text("than before. Be careful! If the viruses reach the top of", 0, 240, 650, 20);
        text("the screen you will lose 3 points but you will take two of", 0, 260, 650, 20);
        text("the viruses with you. If you reach 0 points, it’s game over.", 0, 280, 650, 20);
        text("You can only clear a virus swarm by clearing all of the rows.", 0, 300, 650, 20);
        text("But don’t worry there’s help! Click the “Mode” button for", 0, 340, 650, 20);
        text("helpful hints underneath each column! It will automatically", 0, 360, 650, 20);
        text("show the powers of 2, but you can show the actual (decimal)", 0, 380, 650, 20);
        text(" numbers by clicking it twice!", 0, 400, 650, 20);
        playButton.drawButton();
    } else if (gameMode == 1) {
        if (bossState && grid.size() == 0) {
            bossState = false;
            level++;
            score = 0;
            speed += 30 + level * 15;
        }
        image(img, WIN_W + W*2, 300, 150, 150);
        //check for points
        //if (grid.size() > 8) {
        //    exit();
        //}
        //draw grid
        for (int i = 0; i < grid.size(); i++) {
            grid.get(i).drawRow(i);
        }
        fCount++;
        if (fCount == speed) {
            fCount = 0;
            if (grid.size() < 8) {
                grid.add(new Row(level));
            } else {
                score -= 3;
                if (score < 0) {
                    gameMode = 0;
                }
                grid.remove(0);
                grid.remove(1);
            }
        }
        progress();
        modeButton.drawButton();
        layout(hintMode);
    }
    smooth();
}

void progress() {
    textSize(20);
    fill(256, 256, 256);
    if (!bossState)
        text("Level " + level, WIN_W + W*2, 0, 150, 25);
    else
        text("SWARM " + level, WIN_W + W*2, 0, 150, 25);
    stroke(66, 191, 244);
    fill(16, 204, 56);
    for (int i = 9; i >= 0; i--) {
        if (9 - i >= score) {
            fill(0, 0, 0);
        }
        rect(WIN_W + W*2 + 50, (i+1)*25, 50, 25);
    }
}

void mousePressed() {
    if (gameMode == 0) {
        if (startButton.mouseOver())
            gameMode = 2;
    } else if (gameMode == 2) {
        if (mouseX > 190 + (2 * 50) && mouseX < 190 + (2 * 50) + 50 && mouseY > 130 && mouseY < 130 + H) {
            gameMode = 3;
        }
    } else if (gameMode == 3) {
        if (playButton.mouseOver()) {
            gameMode = 1;
            gameSetup();
        }
    } else {
        if ((WIN_W - mouseX) >= 0 && (WIN_H - mouseY) >=0) {
            int x = (WIN_W - mouseX)/50;
            int y = (WIN_H - mouseY)/50;
            //println(x + " " + y);
            //println(grid.size() + " " + (y < grid.size()));
            if (y < grid.size() && x <= level) {
                grid.get(y).flip(x);
                if (grid.get(y).check()) {
                    grid.remove(y);
                    if (score != 10) {
                        score++;
                        if (score == 10 && !bossState) {                        
                            fCount = 0;
                            speed -= 20;
                            grid.add(new Row(level));
                            grid.add(new Row(level));
                            grid.add(new Row(level));
                            fill(255);
                            rect(160, 100, 350, 100);
                            fill(0);
                            textSize(22);
                            text("VIRUS SWARM:", 325, 125);
                            text("Clear all rows to proceed.", 330, 145);
                            text("press space to continue", 330, 165);
                            pause=true;
                            noLoop();

                            bossState = true;
                        }
                    }
                }
            }
        }
        if (modeButton.mouseOver()) {
            hintMode++;
            if (hintMode == 3) {
                hintMode = 0;
            }
        }
    }
}
void keyPressed() {
    //only allows pausing if the game is being played
    if (gameMode == 1) {
        final int k = keyCode;
        //if keyPressed == spacebar key
        if (k == ' ')
        {
            //pauses all of the drawing, but not the music
            if (looping) {
                fill(255);
                rect(160, 100, 350, 70);
                fill(0);
                textSize(22);
                text("Game Paused.", 325, 125);
                text("Press space to resume.", 325, 145);
                pause = true;
                noLoop();
            } else {
                //resume all drawing
                pause = false;
                loop();
            }
        }
    }
}
void gradient() {
    //create the linear gradient for the start page
    for (int i=20; i<height-100; i++) {
        stroke(0, i-150, i-100);
        line(0, i, width, i);
    }
    text("save_nibbler", 325, 30);
}
void layout(int hintMode) {
    if (hintMode == 0) { // Easy Mode
        for (int i=0; i<level+1; i++) {
            int num = (int)pow(2, i);
            fill(255);
            textSize(32);
            text(num, 375 - (50 * i), 420);
        }
    } else if (hintMode == 1) { // Regular Mode
        for (int i = 0; i < level + 1; i++) {
            fill(255);
            textSize(20);
            text(i, 385 - (50 * i), 410);
            textSize(32);
            text("2", 375 - (50 * i), 420);
        }
    }
}