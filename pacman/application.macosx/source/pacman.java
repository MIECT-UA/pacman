import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.io.*; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pacman extends PApplet {





// Par\u00e2metros do labirinto
int nCol, nLin;          // n\u00ba de linhas e de colunas
int tamanho = 50;        // tamanho (largura e altura) das c\u00e9lulas do labirinto  
int espacamento = 2;     // espa\u00e7o livre emtre c\u00e9lulas
float margemV, margemH;  // margem livre na vertical e na horizontal para assegurar que as c\u00e9lulas s\u00e3o quadrangulares
int corObstaculos =  color(100, 0 , 128);      // cor de fundo dos obst\u00e1culos

// Posicao, tamanho e cor do Pacman
float px, py, pRaio;
int pacColor = color(255, 253, 56);

//velocidade na horizontal e vertical do Pacman
float vx, vy; 
 
// variaveis relacionadas com os fantasmas
int fantasmas = 4;
float[][] pFantasmas = new float[fantasmas][3];
int[] ghostColor = {color(66, 197, 244) /* azul */, color(244, 164, 66)/* laranja */, 
                      color(244, 75, 66)/* vermelho */, color(247, 173, 211)/* rosa */};
float[] vFantasmas = {1.7f, 1.5f, 1.95f, 2.1f};
int[][] mapaFantasmas;
boolean[] obstacle = {false, false, false, false};
boolean[] ableUp = {true, true, true, true}, ableDown = {true, true, true, true}, 
          ableLeft = {true, true, true, true}, ableRight = {true, true, true, true};
int[] dirObstaculoFantasma = new int[4];

// matriz e counter da comida
int[][] mapaComida;
int foodCounter = 0;

// outras variaveis
boolean jogoIniciado = false;
boolean gameWon = false;
boolean gameLost = false;
boolean gameInstructions = true; // false;
float dificuldade;
float facil = 3.0f, medio = 2.70f, dificil = 2.15f;
String nivel = "secreto";
int pontuacao = 0;
PImage introPac;
SoundFile menu, game;

// variables for message screens
int screenDuration;
int messageScreenDuration = 1900;

// variable that stores velocities, used in pause/unpause functionality
float[] stopVel = new float[2];
boolean paused = false;
boolean cheatList = false;

// variables for eat mode cheat code
boolean eatMode = false;
boolean[] ghostEaten = new boolean[4];

// extra speed variable for increase/decrease velocity cheat codes
float extraSpeed = 0;

// flag for cheat codes used
boolean cheatsUsed = false;

public void setup() {

  // Definir o tamanho da janela; notar que size() n\u00e3o aceita vari\u00e1veis.
  
  background(0);
  
  // icone e titulo da janela                                                                                                                      
  surface.setIcon(loadImage("icon.png"));
  surface.setTitle("Pacman");
  
  nCol = (int)width/tamanho;
  nLin = (int)height/tamanho;

  // Assegurar que n\u00ba de linhas e n\u00ba de colunas \u00e9 maior ou igual a 5
  assert nCol >= 5 && nLin >= 5;

  // Determinar margens para limitar a \u00e1rea \u00fatil do jogo 
  margemV = (width - nCol * tamanho) / 2.0f;
  margemH = (height - nLin * tamanho) / 2.0f;
  
  // Inicializar o Pacman e as estruturas internas de comida e fantasmas
  pRaio = tamanho / 2;
  
  mapaComida = new int[nCol][nLin];
  mapaFantasmas = new int[nCol+2][nLin+2];
  
  // Inicializar imagens e sons
  introPac = loadImage("pacman.png");
  menu = new SoundFile(this, "menu.mp3");
  game = new SoundFile(this, "game.mp3");
  
  menu.loop();
  
  frameRate(60);
}

public void draw(){
  background(0);
  
  // Menu + pontuacoes
  if (!jogoIniciado) {
    // menu
    fill(0, 0);
    stroke(pacColor);
    strokeWeight(espacamento);
    
    image(introPac, margemH*2, 0, 0.371875f*(height - 2*margemV), height - 2*margemV);
    
    rect(margemH, margemV, width*2/3, height - 2*margemV);
    for (int i = 0; i < 4; i++) {
      rect(margemH*2 + width*2/3, margemV*(i+1) + (height - 5*margemV)*i/4, width*1/3 - 3*margemH,  (height - 5*margemV)/4);
    }
    
    fill(pacColor);
    textSize(120);
    text("P", 200, 125);
    textSize(60);
    text("acman", 250, 125);
    
    fill(color(255, 255, 255));
    text("F\u00e1cil", 200, 240); 
    text("M\u00e9dio", 200, 360); 
    text("Dif\u00edcil", 200, 480); 

    // highscores
    fill(pacColor);
    textSize(25);
    text("F\u00e1cil", margemH*3 + width*2/3, margemV*3.36f); 
    text("M\u00e9dio", margemH*3 + width*2/3, margemV*4.39f + (height - 5*margemV)*1/4); 
    text("Dif\u00edcil", margemH*3 + width*2/3, margemV*5.43f + (height - 5*margemV)*2/4); 
    text("Cheat Codes", margemH*3 + width*2/3, margemV*6.45f + (height - 5*margemV)*3/4); 
    
    try {
      File fout = new File("highscores.txt");
      if(fout.exists()){
        Scanner input = new Scanner(fout);
        int[][] scoresArray = {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}};
        while(input.hasNextLine()) {
          String line = input.nextLine();
          String[] parts = line.split(":");
          
          int index = 3;
          switch (parts[0]) {
            case "Facil":
              index = 0;
              break;
            case "Medio":
              index = 1;
              break;
            case "Dificil":
              index = 2;
              break;
            // por omissao = cheat codes
          }
          for(int i = 0; i < 3; i++) {
            int temp = Integer.parseInt(parts[1]);
            if (temp > scoresArray[index][i]) {
              if (i != 2) {
                if (i == 0) {
                  scoresArray[index][i+2] = scoresArray[index][i+1];
                }
                scoresArray[index][i+1] = scoresArray[index][i];
              }
              scoresArray[index][i] = temp;
              break;
            }
          }
        }
        input.close();
        
        fill(color(255, 255, 255));
        // escrever cada highscore
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 3; j++) {
            text(scoresArray[i][j], margemH*13 + width*2/3, margemV*(i+6.25f) + (height - 5*margemV)*(i)/4 + 27*j); 
          }
        }
      }
    } catch (IOException e) {
        e.printStackTrace();
    }
    
  } else if (gameInstructions) {
  
    fill(0);
    stroke(pacColor);
    strokeWeight(espacamento);
    rect(margemH, margemV, width - 2*margemH, height - 2*margemV);
    
    fill(pacColor);
    textSize(40);
    text("Como jogar", 100, 100);  
    fill(255);
    textSize(30);
    text("  Usa as setas ou as teclas WASD para", 50, 150);
    text("movimentares o pacman. ", 50, 190); 
    text("  O objetivo \u00e9 comeres todas os pontos", 50, 240);
    text("brancos, mas cuidado com os fantasmas!", 50, 280);
    text("Se eles te apanharem, perdes o jogo!", 50, 320);
    text("  Carrega no rato ou em qualquer tecla", 50, 370); 
    text("para continuares.", 50, 410);
    
    textSize(15);
    text("PS. Carrega em 'C'  ;)", 555, 505);
  
  } else if (gameWon) {
    fill(0);
    stroke(pacColor);
    strokeWeight(espacamento);
    rect(margemH, margemV, width - 2*margemH, height - 2*margemV);
    
    fill(pacColor);
    textSize(100);
    text("Parab\u00e9ns!", 100, 200);
    fill(255);
    textSize(40);
    text("Venceste o n\u00edvel " + nivel + ", com ", 40, 300); 
    text("uma pontua\u00e7\u00e3o de " + String.valueOf(pontuacao) + " pontos!", 40, 370);
    
    if (millis() - screenDuration > messageScreenDuration) {
      // exit win screen
      gameWon = false;
      // end game
      terminarJogo();
    }
    
  } else if (gameLost) {
    fill(0);
    stroke(pacColor);
    strokeWeight(espacamento);
    rect(margemH, margemV, width - 2*margemH, height - 2*margemV);
    
    fill(pacColor);
    textSize(85);
    //text("Oh n\u00e3o!", 65, 200);
    text("Ghostbusted!", 65, 200);
    fill(255);
    textSize(40);
    text("Perdeste no n\u00edvel " + nivel + ", com ", 40, 300); 
    text("uma pontua\u00e7\u00e3o de " + String.valueOf(pontuacao) + " pontos!", 40, 370);
    
    if (millis() - screenDuration > messageScreenDuration) {
      // exit lose screen
      gameLost = false;
      // end game
      terminarJogo();
    }
  } else if (cheatList) {
    fill(0);
    stroke(pacColor);
    strokeWeight(espacamento);
    rect(margemH, margemV, width - 2*margemH, height - 2*margemV);
    
    // titulo
    fill(pacColor);
    textSize(30);
    text("Cheat Codes", width/2 - 90, 60);
    
    // seccao de cores
    fill(pacColor, 200);
    textSize(27);
    text("Mudar o tema", 70, 100);
    
    // teclas e o seu significado
    textSize(20);
    fill(pacColor);
    text("G", 50, 130);
    fill(255);
    text("Tema Verde", 100, 130);
    fill(pacColor);
    text("B", 50, 160);
    fill(255);
    text("Tema Cinzento", 100, 160);
    fill(pacColor);
    text("I", 50, 190);
    fill(255);
    text("Inverter o tema original", 100, 190);
    fill(pacColor);
    text("Y", 50, 220);
    fill(255);
    text("Tema original", 100, 220);
    
    // seccao dos fantasmas
    fill(pacColor, 200);
    textSize(27);
    text("Fantasmas", 70, 260);
    
    // teclas e o seu significado
    textSize(20);
    fill(pacColor);
    text("F", 50, 290);
    fill(255);
    text("Congelar os fantasmas", 100, 290);
    fill(pacColor);
    text("U", 50, 320);
    fill(255);
    text("Descongelar os fantasmas", 100, 320);
    fill(pacColor);
    text("E", 50, 360);
    fill(255);
    text("Ativar/ Desativar modo", 100, 350);
    text("de comer fantasmas", 100, 370);
    
    // seccao de comandos
    fill(pacColor, 200);
    textSize(27);
    text("Sair ou Pausar", 70, 410);
    
    // teclas e o seu significado
    textSize(20);
    fill(pacColor);
    text("P", 50, 450);
    fill(255);
    text("Pausa ou continua o jogo", 100, 450); 
    fill(pacColor);
    text("Q", 50, 480);
    fill(255);
    text("Sai do jogo atual", 100, 480); 
    
    // secao da velocidade do pacman
    fill(pacColor, 200);
    textSize(27);
    text("Velocidade", 470, 100);
    
    // teclas e o seu significado
    textSize(20);
    fill(pacColor);
    text("V", 420, 130);
    text("ou +", 405, 150);
    fill(255);
    text("Aumenta a velocidade", 470, 130); 
    text("do pacman", 470, 150);
    fill(pacColor);
    text("U", 420, 190);
    fill(255);
    text("Rep\u00f5e a velocidade", 470, 180); 
    text("original do pacman", 470, 200);
    
    
    // seccao de outros comandos
    fill(pacColor, 200);
    textSize(27);
    text("Outros", 470, 240);
    
    // teclas e o seu significado
    textSize(20);
    fill(pacColor);
    text("R", 420, 270);
    fill(255);
    text("Rep\u00f5e as pontua\u00e7\u00f5es", 470, 270);
    fill(pacColor);
    text("C", 420, 300);
    fill(255);
    text("Abre/Fecha esta lista", 470, 300);
    
  } else {  
    
    desenharLabirinto();
    desenharPontos();
    desenharPacman();
    desenharFantasmas();
    comerPontos();
    orientarPacman(0);
    moverPacman();
    moverFantasmas();
    
    if (paused) { 
      // draw pause symbol on top of game
      fill(pacColor);
      noStroke();
      rect(width/2.3f - 2*margemH, 150, 4*margemH, height/3);
      rect(width/2.3f + 6*margemH, 150, 4*margemH, height/3);
    }
  }  
}

public void keyPressed() {
  if (gameInstructions) {
    gameInstructions = false;
  } 
  if (key == CODED) { 
    // pacman direction
    if (keyCode == UP) {
      orientarPacman(1);
    } else if (keyCode == DOWN) {
      orientarPacman(2);
    } else if (keyCode == LEFT) {
      orientarPacman(3);
    }  else if (keyCode == RIGHT) {
      orientarPacman(4);
    }
  } else {
    if (key == 'W' || key == 'w') {
      orientarPacman(1);
    } else if (key == 'S' || key == 's') {
      orientarPacman(2);
    } else if (key == 'A' || key == 'a') {
      orientarPacman(3);
    } else if (key == 'D' || key == 'd') {
      if (jogoIniciado) {
        orientarPacman(4);
      } else { // dificulty seletor
        startGame(dificil);
      }
    }
    else if (key == 'M' || key == 'm'){ 
      if (!jogoIniciado) { // dificulty selector
        startGame(medio);
      }
    } 
    
    else if (key == 'F' || key == 'f') {       // cheat codes
      if (jogoIniciado) { // "F"reeze ghosts
        cheatsUsed = true;
        for (int i = 0; i < fantasmas; i++) {
          vFantasmas[i] = 0;
        } 
      } else { // dificulty seletor
        startGame(facil);
      }
    } else if (key == 'U' || key == 'u') { // "U"nfreeze ghosts
      vFantasmas[0] = 1.7f; 
      vFantasmas[1] = 1.5f; 
      vFantasmas[2] = 1.95f; 
      vFantasmas[3] = 2.14f;
    }
    else if (key == 'E' || key == 'e') { // "E"at mode (pacman can eat ghosts)
      if (!eatMode) {
        cheatsUsed = true;
        eatMode = true;
        for (int i = 0; i < fantasmas; i++) {
          ghostColor[i] = color(2, 90, 232);
        }
      } else {
        for (int i = 0; i < fantasmas; i++) {
          if (ghostEaten[i]) {
            switch (i) {
              case 0:
                pFantasmas[0][0] = centroX(1);
                pFantasmas[0][1] = centroY(1);
                pFantasmas[0][2] = 4;
                break;
              case 1:
                pFantasmas[1][0] = centroX(1);
                pFantasmas[1][1] = centroY(nLin);
                pFantasmas[1][2] = 4;
                break;
              case 2:
                pFantasmas[2][0] = centroX(nCol);
                pFantasmas[2][1] = centroY(1);
                pFantasmas[2][2] = 3;
                break;
              case 3:
                pFantasmas[3][0] = centroX(nCol);
                pFantasmas[3][1] = centroY(nLin);
                pFantasmas[3][2] = 3;
                break;
            }
  
           ghostEaten[i] = false;
          }
        }
        ghostColor[0] = color(66, 197, 244);
        ghostColor[1] = color(244, 164, 66);
        ghostColor[2] = color(244, 75, 66);
        ghostColor[3] = color(247, 173, 211);
        eatMode = false;
      }
    }
    
    else if (key == '+' || key == 'V'|| key == 'v') { // increase "V"elocity
      if (extraSpeed < dificuldade) {
        cheatsUsed = true;
        extraSpeed += 0.1f;
      }
    } else if (key == '-') { // reset extra speed to 0
      extraSpeed = 0;
    }
    
    else if (key == 'Y' || key == 'y') { // "Y"ellow
      pacColor = color(232, 239, 40);
      corObstaculos = color(100, 0 , 128);
    } else if (key == 'G' || key == 'g') { // "G"reen
      pacColor = color(20, 239, 40);
      corObstaculos = color(100, 255, 200);
    } else if (key == 'I' || key == 'i') { // "I"nvert colors
      pacColor = color(100, 0 , 128);
      corObstaculos = color(232, 239, 40);
    } else if (key == 'B' || key == 'b') { 
      // "B"lack (grey [= black and white] pacman and obstacles)
      pacColor = color(140, 140, 140);
      corObstaculos = color(70, 70 , 70);
    }

    else if (key == 'Q' || key == 'q') { // "Q"uit the game
      perder();
    }
    else if (key == ' ' || key == 'P' || key == 'p') { 
      // "P"ause and unpause the game
      if (!paused) {
        // pause
        stopVel[0] = vx;
        stopVel[1] = vy;
        vx = 0;
        vy = 0;
        for (int i = 0; i < fantasmas; i++) {
          vFantasmas[i] = 0; 
        }
      } else { // unpause
        vx = stopVel[0];
        vy = stopVel[1];
        vFantasmas[0] = 1.7f; 
        vFantasmas[1] = 1.5f; 
        vFantasmas[2] = 1.95f; 
        vFantasmas[3] = 2.14f;
      }
      // toggle boolean flag
      paused = !paused;
    }
    
    if (key == 'R' || key == 'r') { // "R"eset highscores
      resetScores();
    }
    
    if (key == 'C' || key == 'c') { // Pases games and shows a list of cheat codes
      if(cheatList) {
        cheatList = false;
        paused = false;
      } else {
        cheatList = true;
        paused = true;
      }
    }
  }
}

public void mouseClicked() {
  if (gameInstructions) {
    gameInstructions = false;
  } else if (cheatList) {
    cheatList = false;
    paused = false;
  } 
  if (!jogoIniciado && (mouseX >= 0) && (mouseX <= width*2/3)) {
     if ((mouseY >= 150) && (mouseY < 300)) { // facil
      nivel = "f\u00e1cil";
      startGame(facil);
    } else if ((mouseY >= 300) && (mouseY < 420)) { // medio
      nivel = "m\u00e9dio";
      startGame(medio);
    } else if ((mouseY >= 420)) { // dificil
      nivel = "dif\u00edcil";
      startGame(dificil);
    }
  }
  // if mouse clicked when on won or lost screens, skip remaining message time
  if ((gameWon) || (gameLost)) {
  // exit screens
      gameWon = false;
      gameLost = false;
      // end game
      terminarJogo();
  }
}

// sets up several variables in order to start the game
public void startGame(float dif) {
  // Repor as condicoes iniciais
  gameInstructions = true;
  foodCounter = 0;
  dificuldade = dif;
  pontuacao = 0;
  extraSpeed = 0;
  
  // Mudar para o som do jogo
  menu.stop();
  game.loop();
  
  // Inicializar o Pacman
  px = centroX(5);
  py = centroY(1);
  
  // Inicializar os fantasmas
  pFantasmas[0][0] = centroX(1);
  pFantasmas[0][1] = centroY(1);
  pFantasmas[0][2] = 4;
  
  pFantasmas[1][0] = centroX(1);
  pFantasmas[1][1] = centroY(nLin);
  pFantasmas[1][2] = 4;
  
  pFantasmas[2][0] = centroX(nCol);
  pFantasmas[2][1] = centroY(1);
  pFantasmas[2][2] = 3;
  
  pFantasmas[3][0] = centroX(nCol);
  pFantasmas[3][1] = centroY(nLin);
  pFantasmas[3][2] = 3;
  
  // Inicializar velocidades
  vx = 1 * dificuldade;
  vFantasmas[0] = 1.7f; 
  vFantasmas[1] = 1.5f; 
  vFantasmas[2] = 1.95f; 
  vFantasmas[3] = 2.14f;
  
  // Ajustar velocidade dos fantasmas
  if ((int)(dif*100) == (int)(facil*100)) {
    for (int i = 0; i < fantasmas; i++) {
      vFantasmas[i] -= 1;
    }
  } else if ((int)(dif*100) == (int)(medio*100)) {
    for (int i = 0; i < fantasmas; i++) {
      vFantasmas[i] -= 0.4f;
    }
  }
  
  // run all the functions that make up the game one time before draw does,
  // in order to set up food and ghost maps
  desenharLabirinto();
  
  // criar mapa de comida e de fantasmas
  for (int i = 0; i < nCol; i++) {
    for (int j = 0; j < nLin; j++) {     
      int c = get((int)centroX(i+1), (int)centroY(j+1));
      if(c != corObstaculos) {
          mapaComida[i][j] = 1;
          mapaFantasmas[i+1][j+1] = 1;
          foodCounter++;
        } else {
          mapaComida[i][j] = 0;
          mapaFantasmas[i+1][j+1] = 0;
        }
     
      mapaFantasmas[0][j+1] = 0;
      mapaFantasmas[nCol+1][j+1] = 1;
    }
  }
  
  // desativar qualquer cheat code
  cheatsUsed = false;
  paused = false;
  eatMode = false;
  ghostColor[0] = color(66, 197, 244);
  ghostColor[1] = color(244, 164, 66);
  ghostColor[2] = color(244, 75, 66);
  ghostColor[3] = color(247, 173, 211);
  for (int i = 0; i < fantasmas; i++) {
    ghostEaten[i] = false;
    dirObstaculoFantasma[i] = 0;
  }
  
  jogoIniciado = true; 
  
  desenharPontos();
  desenharPacman();
  desenharFantasmas();
  comerPontos();
  orientarPacman(0);
  moverPacman();
  moverFantasmas();
  
       
}

/* Guarda a pontuacao e reinicia o jogo */
public void terminarJogo() {
  // mudar para o som do menu
  game.stop();
  menu.loop();
  
  // guardar pontuacao
  try {
        // abrir ficheiro
        File fout = new File("highscores.txt");
        if(!fout.exists()){
          fout.createNewFile();
        }

        // guardar a pontucao, certificando-nos que so guarda 3 highscores
        // para cada categoria
        String highscores = "";
        
        // ler as top 3 pontuacoes de cada categoria
        Scanner input = new Scanner(fout);
        int[][] scoresArray = {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}};
        while(input.hasNextLine()) {
          String line = input.nextLine();
          String[] parts = line.split(":");
          
          int index = 3;
          switch (parts[0]) {
            case "Facil":
              index = 0;
              break;
            case "Medio":
              index = 1;
              break;
            case "Dificil":
              index = 2;
              break;
            // por omissao = foram usados cheat codes
          }
          for(int i = 0; i < 3; i++) {
            int temp = Integer.parseInt(parts[1]);
            if (temp > scoresArray[index][i]) {
              if (i != 2) {
                if (i == 0) {
                  scoresArray[index][i+2] = scoresArray[index][i+1];
                }
                scoresArray[index][i+1] = scoresArray[index][i];
              }
              scoresArray[index][i] = temp; //<>//
              break;
            }
          }
        }
        input.close();
        
        // verficar se a pontucao deste jogo pertece ao top 3 da sua categoria
        int currentGameIndex = 3;
        if (!cheatsUsed) {
          switch ((int)(dificuldade * 100)) {
            case 300:
              currentGameIndex = 0;
              break;
            case 270:
              currentGameIndex = 1;
              break;
            case 215:
              currentGameIndex = 2;
              break;
          }
        }
        for(int i = 0; i < 3; i++) {
            if (pontuacao > scoresArray[currentGameIndex][i]) {
              if (i != 2) {
                if (i == 0) {
                  scoresArray[currentGameIndex][i+2] = scoresArray[currentGameIndex][i+1];
                }
                scoresArray[currentGameIndex][i+1] = scoresArray[currentGameIndex][i];
              }
              scoresArray[currentGameIndex][i] = pontuacao;
              break;
            }
          }
        
        
        // escrever as top 3 pontuacoes de cada categoria
        for (int i = 0; i < 4; i++) {
          String header = "Com Cheat Codes:";
          switch (i){
            case 0:
              header = "Facil:";
              break;
            case 1:
              header = "Medio:";
              break;
            case 2:
              header = "Dificil:";
              break;
          }
          for (int j = 0; j < 3; j++) {
            highscores += header + String.valueOf(scoresArray[i][j]) + "\n";
          }
        }
        
        
        PrintWriter fileOut = new PrintWriter(fout);
        fileOut.write(highscores);
        fileOut.close();

      } catch (IOException e){
        e.printStackTrace();
      }
      
  // reiniciar o jogo
  jogoIniciado = false;
}

/* Termina o jogo quando este foi ganho, mostrando uma mensagem de vitoria */
public void ganhar() {
  // mostar ecra de vitoria
  screenDuration = millis();
  gameWon = true;
}

/* Termina o jogo quando este foi perdido, mostrando uma mensagem de derrota */
public void perder() {
  // mostrar ecra de derrota
  screenDuration = millis();
  gameLost = true;
}

public void moverFantasmas() { 
  // encontrar a posicao do pacman
  int pacX = (int)(Math.round((px + 0.5f - margemH/2)/tamanho));
  int pacY = (int)(Math.round((py + 0.5f - margemV/2)/tamanho));
  if ((vx < 0) || (vy < 0)) { 
      // ajustar a posicao se o pacman estiver a ir para cima ou para a esquerda
      pacX = (int)(Math.round((px + 0.5f + margemH*3.3f)/tamanho)); 
      pacY = (int)(Math.round((py + 0.5f + margemV*3.3f)/tamanho));
  }
  
   for (int i = 0; i < fantasmas; i++) {

     float pFx = pFantasmas[i][0];
     float pFy = pFantasmas[i][1];
     
      int x = (int)Math.round((pFx + 0.5f - margemH/2)/tamanho);
      int y = (int)Math.round((pFy + 0.5f - margemV/1.5f)/tamanho);
      
       // ajustar a posicao dos fantasmas, para criar um movimento mais fluido
       if (pFantasmas[i][2] - 1 < 0.1f) { // para cima
         y = (int)Math.round((pFy + 0.5f - margemV*2)/tamanho) + 1;
       } else if (pFantasmas[i][2] - 2 < 0.1f) { // para baixo
         y = (int)Math.round((pFy + 0.5f)/tamanho);
       } else if (pFantasmas[i][2] - 3 < 0.1f) { // para a esquerda
         x = (int)Math.round((pFx + 0.5f - margemH*2)/tamanho) + 1;
       } else if (pFantasmas[i][2] - 4 < 0.1f) { // para a direita
         x = (int)Math.round((pFx + 0.5f - margemH/2.4f)/tamanho);
       } 
                                                                                                                                   
     if (!obstacle[i]) {
       // perseguir pacman
       if ((pacX - x < 0) && (mapaFantasmas[x-1][y] == 1)) { // ir para a esquerda //<>//
         pFx -= vFantasmas[i];
         pFy = centroY(y); 
         pFantasmas[i][2] = 3;
       } else if ((pacX - x > 0) && (mapaFantasmas[x+1][y] == 1)) { // ir para a direita
         pFx += vFantasmas[i];
         pFy = centroY(y); 
         pFantasmas[i][2] = 4;
       } else if ((pacY - y < 0) && (mapaFantasmas[x][y-1] == 1)) { // ir para cima
         pFy -= vFantasmas[i];
         pFx = centroX(x); 
         pFantasmas[i][2] = 1;
       } else if ((pacY - y > 0) && (mapaFantasmas[x][y+1] == 1)) { // ir para baixo
         pFy += vFantasmas[i];
         pFx = centroX(x); 
         pFantasmas[i][2] = 2;
       } else {
         if ((pacX - x < 0.5f) && (pacX - x > -0.5f) && (pacY - y < 0.5f) && (pacY - y > -0.5f)) {
           // certificar que um fantasma esta a tocar o pacman
           if (get((int)px, (int)py) != pacColor) { 
             if (!eatMode) {
               perder();
             } else { // comer fantasma
               ghostEaten[i] = true;
               // verificar se todos os fantasmas foram comidos
               boolean ateAll = true;
               for (int j = 0; j < fantasmas; j++) {
                 if (!ghostEaten[j]) {
                   ateAll = false;
                 }
               }
               if (ateAll) {
                 ganhar();
               }
             }
           }
         } else {
           obstacle[i] = true;
         } 
       }
     } else { 
       // ha um obstaculo entre o fantasma e o pacman
       if (dirObstaculoFantasma[i] == 0) { // o obstaculo esta a aparecer pela primeira vez
          if ((pacY != y)) {
            if (((pFantasmas[i][2] - 1 < 0.1f) && (pFantasmas[i][2] - 1 > -0.1f) && (mapaFantasmas[x][y-1] == 0)) || (pacY - y < 0)) { 
              // obstaculo esta acima do fantasma
              dirObstaculoFantasma[i] = 1; 
              contornarObstaculo(i, pacX, pacY, x, y, pFx, pFy);} // obs cima
            else if (((pFantasmas[i][2] - 2 < 0.1f) && (pFantasmas[i][2] - 2 > -0.1f) && (mapaFantasmas[x][y+1] == 0)) || (pacY - y > 0)) { 
              // obstaculo esta abaixo do fantasma
              dirObstaculoFantasma[i] = 2; 
              contornarObstaculo(i, pacX, pacY, x, y, pFx, pFy);} // obs baixo
          } else if (pacX != x) {
            if (((pFantasmas[i][2] - 3 < 0.1f) && (pFantasmas[i][2] - 3 > -0.1f) && (mapaFantasmas[x-1][y] == 0)) || (pacX - x <= 0)) { 
              // obstaculo esta a esquerda do fantasma
              dirObstaculoFantasma[i] = 3; 
              contornarObstaculo(i, pacX, pacY, x, y, pFx, pFy);
            } else if (((pFantasmas[i][2] - 4 < 0.1f) && (pFantasmas[i][2] - 4 > -0.1f) && (mapaFantasmas[x+1][y] == 0)) || (pacX - x > 0))  { 
              // obstaculo esta a direita do fantasma
              dirObstaculoFantasma[i] = 4; 
              contornarObstaculo(i, pacX, pacY, x, y, pFx, pFy);
            }
          }
       } else { // continuar a contornar o obstaculo
         contornarObstaculo(i, pacX, pacY, x, y, pFx, pFy);
       }
       
     pFx = pFantasmas[i][0];
     pFy = pFantasmas[i][1];
     
     }
     
     // colisao com margens
    if (pFx > centroX(nCol)) { 
      pFx -= vFantasmas[i];
      pFx = centroX(x); 
    } else if (pFx < centroX(1)) {
      pFx += vFantasmas[i];
      pFx = centroX(x); 
    } else if (pFy > centroY(nLin)) {
      pFy -= vFantasmas[i];
      pFy = centroY(y); 
    } else if (pFy < centroY(1)) {
      pFy += vFantasmas[i];
      pFy = centroY(y); 
    }
     
     pFantasmas[i][0] = pFx;
     pFantasmas[i][1] = pFy;
     
  }
}

/* Implementa o movimento do Pacman, adicionando a 
 * sua velocidade a sua posicao
 */
public void moverPacman() {
  px += vx;
  py += vy;
}

/* Implenta a inteligencia artificial dos fantasmas para que estes
 * consigam contornar obstaculos
 */
public void contornarObstaculo(int fantasma, int pacX, int pacY, int x, int y, float pFx, float pFy) {

  if (dirObstaculoFantasma[fantasma] == 1) { // obstacle above
     // while obstacle above
     if(mapaFantasmas[x][y-1] != 1) {
     // move either left or right until obstacle is no longer above
       if((mapaFantasmas[x-1][y] == 1) && (ableLeft[fantasma])) {  // if pac is on the left
         pFx -= vFantasmas[fantasma];
         pFy = centroY(y); 
       } else if ((mapaFantasmas[x+1][y] == 1) && (ableRight[fantasma])) { // go right
         ableLeft[fantasma] = false;
         pFx += vFantasmas[fantasma];
         pFy = centroY(y); 
       } else {
       // go down until able to go either left or rigt 
         if (mapaFantasmas[x][y+1] == 1) {
           pFy += vFantasmas[fantasma];
           pFx = centroX(x); 
           
           ableLeft[fantasma] = (mapaFantasmas[x-1][y] == 1);
           ableRight[fantasma] = (mapaFantasmas[x+1][y] == 1);
         }
       }
     }
     if (pacY - y <= 0){ // ir para cima
       if (mapaFantasmas[x][y-1] == 1) {
         pFy -= vFantasmas[fantasma];
         pFx = centroX(x); 
         pFantasmas[fantasma][2] = 1;
       }
     } else {
       obstacle[fantasma] = false;
       dirObstaculoFantasma[fantasma] = 0;
     }
   } 
   
   else if (dirObstaculoFantasma[fantasma] == 2) {
   // while obstacle below
     if(mapaFantasmas[x][y+1] != 1) { 
     // move either left or right until obstacle is no longer below
       if((mapaFantasmas[x-1][y] == 1) && (ableLeft[fantasma])) {  // if pac is on the left
         pFx -= vFantasmas[fantasma];
         pFy = centroY(y); 
       } else if ((mapaFantasmas[x+1][y] == 1) && (ableRight[fantasma])) { // go right
         ableLeft[fantasma] = false;
         pFx += vFantasmas[fantasma];
         pFy = centroY(y); 
       } else {
       // go up until able to go either left or rigt
         if (mapaFantasmas[x][y-1] == 1) {
           pFy -= vFantasmas[fantasma];
           pFx = centroX(x); 
           
           ableLeft[fantasma] = (mapaFantasmas[x-1][y] == 1);
           ableRight[fantasma] = (mapaFantasmas[x+1][y] == 1);
         }
       }
     }
     if (pacY - y > 0) {  // ir para baixo
       if (mapaFantasmas[x][y+1] == 1) {
         pFy += vFantasmas[fantasma];
         pFx = centroX(x); 
         pFantasmas[fantasma][2] = 2;
       }
     } else {
       obstacle[fantasma] = false;
       dirObstaculoFantasma[fantasma] = 0;
     }
   }
   
   else if (dirObstaculoFantasma[fantasma] == 3) {
     // enquanto houver um obstaculo a esquerda do fantasma
     if(mapaFantasmas[x-1][y] != 1) {
       // ir para cima ou para baixo ate deixar de existir um obstaculo a direita do fantasma
       if((mapaFantasmas[x][y-1] == 1) && (ableUp[fantasma])) {   // ir para cima
         pFx = centroX(x); 
         pFy -= vFantasmas[fantasma];
       } else if ((mapaFantasmas[x][y+1] == 1) && (ableDown[fantasma])) {  // ir para baixo
         ableUp[fantasma] = false;
         pFx = centroX(x); 
         pFy += vFantasmas[fantasma];
       } else {
         // ir para a direita ate ser possivel ir para cima ou para baixo
         if (mapaFantasmas[x][y+1] == 1) {
           pFx += vFantasmas[fantasma];
           pFy = centroY(y);
           
           ableUp[fantasma] = mapaFantasmas[x][y-1] == 1;
           ableDown[fantasma] = mapaFantasmas[x][y+1] == 1;
         }
       }
     }
     if (pacX - x <= 0){ // ir para a esquerda
       if (mapaFantasmas[x-1][y] == 1) {
         pFx -= vFantasmas[fantasma];
         pFy = centroY(y); 
         pFantasmas[fantasma][2] = 3;
       }
     } else {
       obstacle[fantasma] = false;
       dirObstaculoFantasma[fantasma] = 0;
     }  
   } else { // dirObstaculoFantasma[fantasma] = 4  
     // enquanto houver um obstaculo a direita do fantasma
     if(mapaFantasmas[x+1][y] != 1) {
       // ir para cima ou para baixo ate deixar de existir um obstaculo a direita do fantasma
       if((mapaFantasmas[x][y-1] == 1) && (ableUp[fantasma])) {  // ir para cima
         pFx = centroX(x); 
         pFy -= vFantasmas[fantasma];
       } else if ((mapaFantasmas[x][y+1] == 1) && (ableDown[fantasma])) { // ir para baixo
         ableUp[fantasma] = false;
         pFx = centroX(x); 
         pFy += vFantasmas[fantasma];
       } else {
         // ir para a esquerda ate ser possivel ir para cima ou para baixo
         if (mapaFantasmas[x][y-1] == 1) {
           pFx -= vFantasmas[fantasma];
           pFy = centroY(y);
           
           ableUp[fantasma] = (mapaFantasmas[x][y-1] == 1);
           ableDown[fantasma] = (mapaFantasmas[x][y+1] == 1);
         }
       }
     }
     if (pacX - x > 0){ // ir para a direita
       if (mapaFantasmas[x+1][y] == 1) {
         pFx += vFantasmas[fantasma];
         pFy = centroY(y); 
         pFantasmas[fantasma][2] = 4;
       }
     } else {
       obstacle[fantasma] = false;
       dirObstaculoFantasma[fantasma] = 0;
     } 
   } 
     
 
   pFantasmas[fantasma][0] = pFx;
   pFantasmas[fantasma][1] = pFy;
}


/* Orienta o pacman de acordo com a direcao passada como argumento (0 = nao ha mudanca,
 * 1 = ir para cima, 2 = ir para baixo, 3 = ir para a esquerda, 4 = ir para a direita),
 * alterando as suas velocidades nos eixos x e y, bem como o alinhando 
 * quando ha mudancas de direcao
 */
public void orientarPacman(int direction) { 
  int x = (int)(Math.round((px + 0.5f - margemH/2)/tamanho));
  int y = (int)(Math.round((py + 0.5f - margemV/2)/tamanho));
  
  // se o jogo estivar pausado, e uma tecla diretional 
  // tiver sido carregada, sair da pausa
  if ((direction != 0 ) && (paused)) {
    vx = stopVel[0];
    vy = stopVel[1];
    vFantasmas[0] = 1.7f; 
    vFantasmas[1] = 1.5f; 
    vFantasmas[2] = 1.95f; 
    vFantasmas[3] = 2.14f;
    paused = false;
  }
         
  // mudar a direcao do pacman, se for o caso       
  switch (direction) {
      
    case 1: // cima
      // ajustar as coordenadas se o pacman for para cima
      x = (int)(Math.round((px + 0.5f + margemH*3.3f)/tamanho)); 
      y = (int)(Math.round((py + 0.5f + margemV*3.3f)/tamanho));
      
      // check for collisons
      if ((y > 1) && (get((int)centroX(x), (int)centroY(y-1)) != corObstaculos)) {
        vx = 0;
        vy = -1 * (dificuldade + extraSpeed);
        px = centroX(x);
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 2: // baixo
      if ((y < nLin) && (get((int)centroX(x), (int)centroY(y+1)) != corObstaculos)) {
        vx = 0;
        vy = 1 * (dificuldade + extraSpeed);
        px = centroX(x);
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 3: // esquerda  
      // ajustar as coordenadas se o pacman estiver a ir para a esquerda
      x = (int)(Math.round((px + 0.5f + margemH*3.3f)/tamanho)); 
      y = (int)(Math.round((py + 0.5f + margemV*3.3f)/tamanho));
      
      if ((x > 1) && (get((int)centroX(x-1), (int)centroY(y)) != corObstaculos)) {
        vy = 0;
        vx = -1 * (dificuldade + extraSpeed);
        py = centroY(y); 
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 4: // direita    
      if ((x < nCol) && (get((int)centroX(x+1), (int)centroY(y)) != corObstaculos)) { //
        vy = 0;
        vx = 1 * (dificuldade + extraSpeed);
        py = centroY(y); 
      } else {
        vx = 0;
        vy = 0;
      }
      break;
  }
 

  // ajustar posicao se o pacman for para cima ou para a esquerda
  if (vx < 0 || vy < 0) { 
    x = (int)(Math.round((px + 0.5f + margemH*3.3f)/tamanho)); 
    y = (int)(Math.round((py + 0.5f + margemV*3.3f)/tamanho));
  }

  // colisao com obstaculos sem haver mudanca de direcao
  if ((vy < 0) && (get((int)centroX(x), (int)centroY(y-1)) == corObstaculos) || 
      (vy > 0) && (get((int)centroX(x), (int)centroY(y+1)) == corObstaculos) ||
      (vx < 0) && (get((int)centroX(x-1), (int)centroY(y)) == corObstaculos) ||
      (vx > 0) && (get((int)centroX(x+1), (int)centroY(y)) == corObstaculos)) {
        vx = 0;
        vy = 0;
        px = centroX(x); 
        py = centroY(y); 
  }

  // colisao com margens
  if((px > centroX(nCol)) || (px < centroX(1))) {
    vx = 0;
    px = centroX(x); 
  } else if((py > centroY(nLin)) || (py < centroY(1))) {
    vy = 0;
    py = centroY(y); 
  }
}

/* Desenha os quatro fantasmas, tendo em atencao
 * a direcao para onde os olhos estam virados
 */
public void desenharFantasmas() {
  
  for (int i = 0; i < fantasmas; i++) {
    if (!ghostEaten[i]) {
      fill(ghostColor[i]);
      float raioFant = pRaio/3.0f;
      pFantasmas[i][1] -= 3.5f; // fazer o fantasma mais "alto" que o pacman
      
      // desenhar corpo do fantasma
      ellipse(pFantasmas[i][0], pFantasmas[i][1], pRaio, pRaio);
      rect(pFantasmas[i][0] - pRaio/2.0f, pFantasmas[i][1], pRaio, pRaio/1.5f);
      
      // desenhar cauda do fantasma, composta por 3 circulos
      ellipse(pFantasmas[i][0] - raioFant, pFantasmas[i][1] + pRaio/1.5f, pRaio/3.0f, pRaio/3.0f);
      ellipse(pFantasmas[i][0], pFantasmas[i][1] + pRaio/1.5f, pRaio/3.0f, pRaio/3.0f);
      ellipse(pFantasmas[i][0] + raioFant, pFantasmas[i][1] + pRaio/1.5f, pRaio/3.0f, pRaio/3.0f);
      
      
      // adicionar olhos ao fantasma
      fill (255);
      ellipse(pFantasmas[i][0] - pRaio/4.2f, pFantasmas[i][1], pRaio/3, pRaio/2.5f);
      ellipse(pFantasmas[i][0] + pRaio/4.2f, pFantasmas[i][1], pRaio/3, pRaio/2.5f);
      
      // adicionar iris
      fill(88, 135, 211);
      float tamanhoIris = pRaio/5;
      switch ((int)Math.round(pFantasmas[i][2])) {
        case 1: // fantasma a andar para cima
          ellipse(pFantasmas[i][0] - pRaio/4.2f, pFantasmas[i][1] - pRaio/8, tamanhoIris, tamanhoIris);
          ellipse(pFantasmas[i][0] + pRaio/4.2f, pFantasmas[i][1] - pRaio/8, tamanhoIris, tamanhoIris);
          break;
        case 2: // fantasma a andar para baixo
          ellipse(pFantasmas[i][0] - pRaio/4.2f, pFantasmas[i][1] + pRaio/8, tamanhoIris, tamanhoIris);
          ellipse(pFantasmas[i][0] + pRaio/4.2f, pFantasmas[i][1] + pRaio/8, tamanhoIris, tamanhoIris);
          break;
        case 3: // fantasma a andar para a esquerda
          ellipse(pFantasmas[i][0] - pRaio/4.2f - pRaio/10, pFantasmas[i][1], tamanhoIris, tamanhoIris);
          ellipse(pFantasmas[i][0] + pRaio/4.2f - pRaio/10, pFantasmas[i][1], tamanhoIris, tamanhoIris);
          break;
        case 4: // fantasma a andar para a direita
          ellipse(pFantasmas[i][0] - pRaio/4.2f + pRaio/10, pFantasmas[i][1], tamanhoIris, tamanhoIris);
          ellipse(pFantasmas[i][0] + pRaio/4.2f + pRaio/10, pFantasmas[i][1], tamanhoIris, tamanhoIris);
          break;
      }
      pFantasmas[i][1] += 3.5f; // compensar o ajuste da altura do fantasma
    }
  }
}

/* Remove os pontos brancos (comida) do mapa se o pacman lhes tocar */
public void comerPontos() {
  int x = (int)(Math.round((px + 0.5f - margemH)/tamanho));
  int y = (int)(Math.round((py + 0.5f - margemV/2)/tamanho));

  // ajustar as coordenadas se o pacaman estiver a ir para cima ou para a esquerda
  if (vx < 0 || vy < 0) { 
    x = (int)(Math.round((px + 0.5f + margemH*3.3f)/tamanho)); 
    y = (int)(Math.round((py + 0.5f + margemV*3.3f)/tamanho));
  } else if (vx > 0) {
    x = (int)(Math.round((px + 0.5f - margemH/2)/tamanho + 0.23f));
  }

  int c = get((int)centroX(x), (int)centroY(y));
  int white = color(255, 255 , 255);
  
  // se for comida (ponto branco), comer
  if (c == white) {  
    if (mapaComida[x-1][y-1] == 1) {
      mapaComida[x-1][y-1] = 0;
      foodCounter--;
      
        // subir pontuacao
        pontuacao += 100 * (5/dificuldade);
        
        // verificar se o jogo foi ganho
        if (foodCounter == 0) {
          ganhar();
        }
    }
  }     
        


}

/* Desenha o pacman - recebe um boolean - verdadeiro 
 * se o pacman anda da esquerda para a direita, falso
 * se o pacman anda da direita para esquerda
 */
public void desenharPacman() {
  fill(pacColor);
  ellipseMode(CENTER);
  noStroke();
  if (vy == 0) {
    if (vx > 0) {
      // arco entre PI/4.0 and PI*7/4.0
      arc(px, py, pRaio, pRaio, map(abs(sin(px * PI/50)), 0, 1, PI/4.0f, 0), map(abs(sin(px * PI/50)), 0, 1, PI*7/4.0f, PI*2), PIE);
    } else {
      // arco entre -PI*3/4.0 and PI*3/4.0
      arc(px, py, pRaio, pRaio, map(abs(sin(px * PI/50)), 0, 1, -PI, -PI*3/4.0f), map(abs(sin(px * PI/50)), 0, 1, PI, PI*3/4.0f), PIE);
    }
  } else if (vy > 0) {
    // arco entre -PI*5/4.0 and PI/4.0
    arc(px, py, pRaio, pRaio, map(abs(sin(py * PI/50)), 0, 1, -PI*3/2.0f, -PI*5/4.0f), map(abs(sin(py * PI/50)), 0, 1, PI/2.0f, PI/4.0f), PIE);
  } else { // vy < 0
    // arco entre -PI/4.0 and PI*5/4.0
    arc(px, py, pRaio, pRaio, map(abs(sin(py * PI/50)), 0, 1, -PI/2.0f, -PI/4.0f), map(abs(sin(py * PI/50)), 0, 1, PI*3/2.0f, PI*5/4.0f), PIE);
  }
}

/* Desenha o ecra do jogo (o fundo e os obstaculos) */
public void desenharLabirinto () {

  // desenha a fronteira da \u00e1rea de jogo
  fill(0);
  stroke(80, 60, 200);
  strokeWeight(espacamento);
  rect(margemH, margemV, width - 2*margemH, height - 2*margemV);

  // Desenha obst\u00e1culos
  if (dificuldade == facil) { // mapa facil
    desenharObstaculo(2, 2, 3, 1);
    desenharObstaculo(6, 2, 3, 1);
    desenharObstaculo(10, 2, 3, 1);
    desenharObstaculo(2, 4, 5, 1);
    desenharObstaculo(8, 4, 6, 1);
    desenharObstaculo(7,6, 1, 1);
    desenharObstaculo(2,6, 3, 2);
    desenharObstaculo(2,9, 6, 1);
    desenharObstaculo(9,6, 1, 4);
    desenharObstaculo(11, 6, 1, 1);
    desenharObstaculo(11, 9, 1, 1);
    desenharObstaculo(13, 6, 1, 4);
  }  else if (dificuldade == medio) {
    // mapa medio
    desenharObstaculo(5, 4, 6, 1);
    desenharObstaculo(3, 2, 4, 1);
    desenharObstaculo(3, 2, 1, 2);
    desenharObstaculo(9, 2, 4, 1);
    desenharObstaculo(12, 2, 1, 2);
    desenharObstaculo(2, 6, 5, 1);
    desenharObstaculo(2, 5, 1, 2);
    desenharObstaculo(9, 6, 5, 1);
    desenharObstaculo(13, 5, 1, 2);
    desenharObstaculo(7, 8, 2, 1);
    desenharObstaculo(2, 8, 2, 1);
    desenharObstaculo(2, 8, 1, 2);
    desenharObstaculo(12, 8, 2, 1);
    desenharObstaculo(13, 8, 1, 2);
    desenharObstaculo(5, 10, 6, 1);
    desenharObstaculo(5, 9, 1, 2);
    desenharObstaculo(10, 9, 1, 2);
  }  else {
    // mapa dificil
    desenharObstaculo(2, 2, 5, 1);
    desenharObstaculo(13, 2, 1, 1);
    desenharObstaculo(8, 2, 4, 1); 
    desenharObstaculo(3, 4, 1, 3);
    desenharObstaculo(5, 4, 1, 5);
    desenharObstaculo(8, 4, 1, 3);
    desenharObstaculo(2, 8, 2, 1);
    desenharObstaculo(1, 4, 1, 3);
    desenharObstaculo(7, 8, 5, 1);
    desenharObstaculo(2, 10, 12, 1);
    desenharObstaculo(13, 6, 1, 3);
    desenharObstaculo(11, 6, 3, 1);
    desenharObstaculo(10, 4, 4, 1); 
  }
  
}

/* Desenha um obst\u00e1culo interno de um labirinto:
 * x: \u00edndice da c\u00e9lula inicial segundo eixo dos X - gama (1..nCol) 
 * y: \u00edndice da c\u00e9lula inicial segundo eixo dos Y - gama (1..nLin)
 * numC: n\u00ba de colunas (c\u00e9lulas) segundo eixo dos X (largura do obst\u00e1culo)
 * numL: n\u00ba de linhas (c\u00e9lulas) segundo eixo dos Y (altura do obst\u00e1culo) 
 */
public void desenharObstaculo(int x, int y, int numC, int numL) {
  float x0, y0, larg, comp;
  
  x0 = margemH + (x-1) * tamanho;
  y0 = margemV + (y-1) * tamanho;
  larg = numC * tamanho;
  comp = numL * tamanho;

  fill(corObstaculos);
  noStroke();
  strokeWeight(espacamento/2);
  rect(x0, y0, larg, comp);
}

/* Desenhar pontos nas c\u00e9lulas vazias (que n\u00e3o fazem parte de um obst\u00e1culo). 
 * Esta fun\u00e7\u00e3o usa a cor de fundo no ecr\u00e3 para determinar se uma c\u00e9lula est\u00e1 
 * vazia ou se faz parte de um obst\u00e1culo.
 */
public void desenharPontos() {
  ellipseMode(CENTER);
  fill(255);
  noStroke();

 
  // se o ponto esta no array, desenhar
  for (int i = 0; i < nCol; i++) {
    for (int j = 0; j < nLin; j++) {
      if (mapaComida[i][j] == 1) {
        ellipse(centroX(i+1), centroY(j+1), pRaio/2, pRaio/2);
      }
    }
  }
}

// transformar o \u00edndice de uma c\u00e9lula em coordenada no ecr\u00e3
public float centroX(int col) {
  return margemH + (col - 0.5f) * tamanho;
}

// transformar o \u00edndice de uma c\u00e9lula em coordenada no ecr\u00e3
public float centroY(int lin) {
  return margemV + (lin - 0.5f) * tamanho;
}

/* Faz o reset de todas as pontuacoes guardadas, ficando todas a 0 */
public void resetScores() {
  try {
        // abrir ficheiro
        File fout = new File("highscores.txt");
        if(fout.exists()){          
          PrintWriter fileOut = new PrintWriter(fout);
          // fazer um overwrite com uma string vazia, que o jogo depois
          // interpretara como todos os scores serem 0
          fileOut.write(""); 
          fileOut.close();
        }
      } catch (IOException e){
        e.printStackTrace();
      }
}



// TODO
// passar todo o codigo para pt

// WISHLIST
// improve even more ghost ai

// BUGS
// jumpy movement (for pac and ghosts) -> can cause unfair and frustrating loss
// pacman can on rare intances go through ghost without being eaten
  public void settings() {  size(720, 520); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "pacman" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
