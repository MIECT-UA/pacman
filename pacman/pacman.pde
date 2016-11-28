import java.util.*;
import java.io.*;


// Parâmetros do labirinto
int nCol, nLin;          // nº de linhas e de colunas
int tamanho = 50;        // tamanho (largura e altura) das células do labirinto  
int espacamento = 2;     // espaço livre emtre células
float margemV, margemH;  // margem livre na vertical e na horizontal para assegurar que as células são quadrangulares
color corObstaculos =  color(100, 0 , 128);      // cor de fundo dos obstáculos

// Posicao, tamanho e cor do Pacman
float px, py, pRaio;
color pacColor = color(255, 253, 56);

//velocidade na horizontal e vertical do Pacman
float vx, vy; 
 
// variaveis relacionadas com os fantasmas
int fantasmas = 4;
float[][] pFantasmas = new float[fantasmas][3];
float[] vFantasmas = {1.7, 1.5, 1.95, 2.14};
int[][][] ghostMap;
boolean[] obstacle = {false, false, false, false};
boolean[] ableUp = {true, true, true, true}, ableDown = {true, true, true, true}, 
          ableLeft = {true, true, true, true}, ableRight = {true, true, true, true};

// matriz da comida
int[][][] foodMap;

// outras variaveis
boolean gameStarted = false;
float dificuldade;
int pontuacao = 0;
PImage introPac;
float facil = 2.60, medio = 2.30, dificil = 1.90;

// variable that stores velocities, used in stop/restart cheat codes
float[] stopVel = new float[2];

// flag for cheat codes used
boolean cheatsUsed = false;

void setup() {

  // Definir o tamanho da janela; notar que size() não aceita variáveis.
  size(720, 520);
  background(0);
  
  nCol = (int)width/tamanho;
  nLin = (int)height/tamanho;

  // Assegurar que nº de linhas e nº de colunas é maior ou igual a 5
  assert nCol >= 5 && nLin >= 5;

  // Determinar margens para limitar a área útil do jogo 
  margemV = (width - nCol * tamanho) / 2.0;
  margemH = (height - nLin * tamanho) / 2.0;
  
  // Inicializar o Pacman e as estruturas internas de comida e fantasmas
  pRaio = tamanho / 2;
  
  foodMap = new int[nCol][nLin][1];
  ghostMap = new int[nCol+2][nLin+2][1];
  
  introPac = loadImage("pacman.png");
 
  frameRate(60);
  
}

void draw(){
  background(0);
  
  // Menu + pontuacoes
  if (!gameStarted) {
    // intro screen
    // menu
    fill(0, 0);
    stroke(pacColor);
    strokeWeight(espacamento);
    
    image(introPac, margemH*2, 0, 0.371875*(height - 2*margemV), height - 2*margemV);
    
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
    text("Fácil", 200, 240); 
    text("Médio", 200, 360); 
    text("Difícil", 200, 480); 

    // highscores
    fill(pacColor);
    textSize(25);
    text("Fácil", margemH*3 + width*2/3, margemV*3.36); 
    text("Médio", margemH*3 + width*2/3, margemV*4.39 + (height - 5*margemV)*1/4); 
    text("Difícil", margemH*3 + width*2/3, margemV*5.43 + (height - 5*margemV)*2/4); 
    text("Cheat Codes", margemH*3 + width*2/3, margemV*6.45 + (height - 5*margemV)*3/4); 
    
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
            case "Easy":
              index = 0;
              break;
            case "Medium":
              index = 1;
              break;
            case "Hard":
              index = 2;
              break;
            // by default = cheat codes used
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
        // print each highscore
        for (int i = 0; i < 4; i++) {
          //text("Médio", margemH*3 + width*2/3, margemV*4.35 + (height - 5*margemV)*1/4); 
          for (int j = 0; j < 3; j++) {
            // rect(x, margemV*(i+1) + (height - 5*margemV)*i/4, width*1/3 - 3*margemH,  (height - 5*margemV)/4);
            text(scoresArray[i][j], margemH*13 + width*2/3, margemV*(i+6.25) + (height - 5*margemV)*(i)/4 + 27*j); 
          }
        }
      }
    } catch (IOException e) {
        e.printStackTrace();
    }
    
  } else {  
    
    desenharLabirinto();
    desenharPontos();
    desenharPacman();
    desenharFantasmas();
    comerPontos();
    orientarPacman(0);
    moverPacman();
    moverFantasmas();
    
  }  
}

void keyPressed() {
  // pacman direction
  if (key == CODED) {
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
      if (gameStarted) {
        orientarPacman(4);
      } else { // dificulty seletor
        startGame(dificil);
      }
    }
    else if (key == 'M' || key == 'm'){ 
      if (gameStarted) {                            // cheat codes
        // restart movement ("M"ovement)
        vx = stopVel[0];
        vy = stopVel[1];
        vFantasmas[0] = 1.7; 
        vFantasmas[1] = 1.5; 
        vFantasmas[2] = 1.95; 
        vFantasmas[3] = 2.14;
      } else { // dificulty selector
        startGame(medio);
      }
    } else if (key == 'N' || key == 'n') { // stop movement ("N"o movement)
      cheatsUsed = true;
      stopVel[0] = vx;
      stopVel[1] = vy;
      vx = 0;
      vy = 0;
      for (int i = 0; i < fantasmas; i++) {
        vFantasmas[i] = 0;
      }
    }
    
    else if (key == 'F' || key == 'f') { // "F"reeze ghosts
      if (gameStarted) {
        cheatsUsed = true;
        for (int i = 0; i < fantasmas; i++) {
          vFantasmas[i] = 0;
        } 
      } else { // dificulty seletor
        startGame(facil);
      }
    } else if (key == 'U' || key == 'u') { // "U"nfreeze ghosts
      vFantasmas[0] = 1.7; 
      vFantasmas[1] = 1.5; 
      vFantasmas[2] = 1.95; 
      vFantasmas[3] = 2.14;
    }
    
    else if (key == 'Y' || key == 'y') { // "Y"ellow
      pacColor = color(232, 239, 40);
      corObstaculos = color(100, 0 , 128);
    } else if (key == 'G' || key == 'g') { // "G"reen
      pacColor = color(20, 239, 40);
      corObstaculos = color(100, 255, 200);
    } else if (key == 'P' || key == 'p') { // "P"urple (color invertion)
      pacColor = color(100, 0 , 128);
      corObstaculos = color(232, 239, 40);
    } else if (key == 'B' || key == 'b') { // "B"lack (grey [= black and white] pacman and obstacles)
      pacColor = color(140, 140, 140);
      corObstaculos = color(70, 70 , 70);
    }
  }
}

void mouseClicked() {
  if (!gameStarted && (mouseX >= 0) && (mouseX <= width*2/3)) {
     if ((mouseY >= 150) && (mouseY < 300)) { // facil
      startGame(facil);
    } else if ((mouseY >= 300) && (mouseY < 420)) { // medio
      startGame(medio);
    } else if ((mouseY >= 420)) { // dificil
      startGame(dificil);
    }
  }
}

// sets up several variables in order to start the game
void startGame(float dif) {
  dificuldade = dif;
  
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
  vFantasmas[0] = 1.7; 
  vFantasmas[1] = 1.5; 
  vFantasmas[2] = 1.95; 
  vFantasmas[3] = 2.14;
  
  // run all the functions that make up the game one time before draw does,
  // in order to set up food and ghost maps
  desenharLabirinto();
  
  // set up foodMap and ghostMap
  for (int i = 0; i < nCol; i++) {
    for (int j = 0; j < nLin; j++) {     
      color c = get((int)centroX(i+1), (int)centroY(j+1));
      if(c != corObstaculos) {
          foodMap[i][j][0] = 1;
          ghostMap[i+1][j+1][0] = 1;
        } else {
          foodMap[i][j][0] = 0;
          ghostMap[i+1][j+1][0] = 0;
        }
     
      ghostMap[0][j+1][0] = 0;
      ghostMap[nCol+1][j+1][0] = 1;
    }
  }
  
  cheatsUsed = false;
  gameStarted = true; 
  
  desenharPontos();
  desenharPacman();
  desenharFantasmas();
  comerPontos();
  orientarPacman(0);
  moverPacman();
  moverFantasmas();
  
       
}

/* Guarda a pontuacao e reinicia o jogo */
void gameOver() {
  // save score
  try {
        // open file
        File fout = new File("highscores.txt");
        if(!fout.exists()){
          fout.createNewFile();
        }

        // write score, making sure there are only 3 highscores for every category
        String highscores = "";
        
        // read top 3 scores from each category
        Scanner input = new Scanner(fout);
        int[][] scoresArray = {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}};
        while(input.hasNextLine()) {
          String line = input.nextLine();
          String[] parts = line.split(":");
          
          int index = 3;
          switch (parts[0]) {
            case "Easy":
              index = 0;
              break;
            case "Medium":
              index = 1;
              break;
            case "Hard":
              index = 2;
              break;
            // by default = cheat codes used
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
        
        // check if current game's score belong in top three
        int currentGameIndex = 3;
        if (!cheatsUsed) {
          switch ((int)(dificuldade * 100)) {
            case 260:
              currentGameIndex = 0;
              break;
            case 230:
              currentGameIndex = 1;
              break;
            case 190:
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
        
        
        // write top 3 scores from each category
        for (int i = 0; i < 4; i++) {
          String header = "With Cheat Codes:";
          switch (i){
            case 0:
              header = "Easy:";
              break;
            case 1:
              header = "Medium:";
              break;
            case 2:
              header = "Hard:";
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
      
  // restart game
  gameStarted = false;
}


void moverFantasmas() { 
  // find pacman position
  int pacX = (int)(Math.round((px + 0.5 - margemH/2)/tamanho));
  int pacY = (int)(Math.round((py + 0.5 - margemV/2)/tamanho));
  if ((vx < 0) || (vy < 0)) { // adjust for paman going up or left
      pacX = (int)(Math.round((px + 0.5 + margemH*3.3)/tamanho)); 
      pacY = (int)(Math.round((py + 0.5 + margemV*3.3)/tamanho));
  }
  
   for (int i = 0; i < fantasmas; i++) {

     float pFx = pFantasmas[i][0];
     float pFy = pFantasmas[i][1];
     
      int x = (int)Math.round((pFx + 0.5 - margemH/2)/tamanho);
      int y = (int)Math.round((pFy + 0.5 - margemV/1.5)/tamanho);
      if ((pFantasmas[i][2] - 1 < 0.1) || (pFantasmas[i][2] - 3 < 0.1)) {
        x = (int)(Math.round((pFx + 0.5 + margemH*3.3)/tamanho)); 
        y = (int)(Math.round((pFy + 0.5 + margemV*3.6)/tamanho));
      }
                                                                                       
                                                                                       // 1 for up, 2 for down, 3 for left, 4 for right
                                                                                       if (pFantasmas[i][2] - 1 < 0.1) { // up
                                                                                         y = (int)Math.round((pFy + 0.5 - margemV*5)/tamanho) + 1;
                                                                                       } else if (pFantasmas[i][2] - 2 < 0.1) { // down
                                                                                         y = (int)Math.round((pFy + 0.5 - margemV/2.8)/tamanho);
                                                                                       } else if (pFantasmas[i][2] - 3 < 0.1) { // left
                                                                                         x = (int)Math.round((pFx + 0.5 - margemH*2.9)/tamanho) + 1;
                                                                                       } else if (pFantasmas[i][2] - 4 < 0.1) { // right
                                                                                         x = (int)Math.round((pFx + 0.5 - margemH/2.4)/tamanho);
                                                                                       } 
                                                                                                                  
                                                                                                                  // text(x, 100*(i+1), 200);
                                                                                                                  // text(y, 100*(i+1), 300);
     
     if (!obstacle[i]) {
       // perseguir pacman
       if ((pacX - x < 0) && (ghostMap[x-1][y][0] == 1)) { // move left  
         pFx -= vFantasmas[i];
         pFy = centroY(y); 
         pFantasmas[i][2] = 3;
       } else if ((pacX - x > 0) && (ghostMap[x+1][y][0] == 1)) { // move right
         pFx += vFantasmas[i];
         pFy = centroY(y); 
         pFantasmas[i][2] = 4;
       } else if ((pacY - y < 0) && (ghostMap[x][y-1][0] == 1)) { // move up
         pFy -= vFantasmas[i];
         pFx = centroX(x); 
         pFantasmas[i][2] = 1;
       } else if ((pacY - y > 0) && (ghostMap[x][y+1][0] == 1)) { // move down
         pFy += vFantasmas[i];
         pFx = centroX(x); 
         pFantasmas[i][2] = 2;
       } else {
         if ((pacX - x < 0.2) && (pacX - x > -0.2) && (pacY - y < 0.2) && (pacY - y > -0.2)) {
           gameOver();
         } else {
           obstacle[i] = true;
         } 
       }
     } else { // there is an obstacle between pacman and ghost
       
       // obstacle above
       if ((pFantasmas[i][2] - 1 < 0.1) || (pacY - y <= 0)) {
           // while obstacle above
           if(ghostMap[x][y-1][0] != 1) {
           // move either left or right until obstacle is no longer above
             if((ghostMap[x-1][y][0] == 1) && (ableLeft[i])) {  // if pac is on the left
               pFx -= vFantasmas[i];
               pFy = centroY(y); 
             } else if ((ghostMap[x+1][y][0] == 1) && (ableRight[i])) { // go right
               ableLeft[i] = false;
               pFx += vFantasmas[i];
               pFy = centroY(y); 
             } else {
             // go down until able to go either left or rigt 
               if (ghostMap[x][y+1][0] == 1) {
                 pFy += vFantasmas[i];
                 pFx = centroX(x); 
                 
                 ableLeft[i] = ghostMap[x-1][y][0] == 1;
                 ableRight[i] = ghostMap[x+1][y][0] == 1;
               }
             }
           }
           if (pacY - y <= 0){ // go up
             if (ghostMap[x][y-1][0] == 1) {
               pFy -= vFantasmas[i];
               pFx = centroX(x); 
               pFantasmas[i][2] = 1;
             }
           } else {
             obstacle[i] = false;
           }
         } 
         
         
        // obstacle below
         else if ((pFantasmas[i][2] - 2 < 0.1) || (pacY - y > 0)) {
           // while obstacle below
           if(ghostMap[x][y+1][0] != 1) { 
           // move either left or right until obstacle is no longer below
             if((ghostMap[x-1][y][0] == 1) && (ableLeft[i])) {  // if pac is on the left
               pFx -= vFantasmas[i];
               pFy = centroY(y); 
             } else if ((ghostMap[x+1][y][0] == 1) && (ableRight[i])) { // go right
               ableLeft[i] = false;
               pFx += vFantasmas[i];
               pFy = centroY(y); 
             } else {
             // go up until able to go either left or rigt
               if (ghostMap[x][y-1][0] == 1) {
                 pFy -= vFantasmas[i];
                 pFx = centroX(x); 
                 
                 ableLeft[i] = ghostMap[x-1][y][0] == 1;
                 ableRight[i] = ghostMap[x+1][y][0] == 1;
               }
             }
           }
           if (pacY - y > 0) { // go up
             if (ghostMap[x][y+1][0] == 1) {
               pFy += vFantasmas[i];
               pFx = centroX(x); 
               pFantasmas[i][2] = 2;
             }
           } else {
             obstacle[i] = false;
           }
         } 
         
         
         // obstacle on the left
         else if ((pFantasmas[i][2] - 3 < 0.1) || (pacX - x <= 0)) {
           // while obstacle on the left
           if(ghostMap[x-1][y][0] != 1) {
           // move either up or down until obstacle is no longer on the left
             if((ghostMap[x][y-1][0] == 1) && (ableUp[i])) {  // go up
               pFx = centroX(x); 
               pFy -= vFantasmas[i];
             } else if ((ghostMap[x][y+1][0] == 1) && (ableDown[i])) { // go down
               ableUp[i] = false;
               pFx = centroX(x); 
               pFy += vFantasmas[i];
             } else {
             // go right until able to go either up or down
               if (ghostMap[x][y+1][0] == 1) {
                 pFx += vFantasmas[i];
                 pFy = centroY(y);
                 
                 ableUp[i] = ghostMap[x][y-1][0] == 1;
                 ableDown[i] = ghostMap[x][y+1][0] == 1;
               }
             }
           }
           if (pacX - x <= 0){ // go left
             if (ghostMap[x-1][y][0] == 1) {
               pFx -= vFantasmas[i];
               pFy = centroY(y); 
               pFantasmas[i][2] = 3;
             }
           } else {
             obstacle[i] = false;
           }  
         } 
         
         // obstacle is on the right
         else if ((pFantasmas[i][2] - 4 < 0.1) || (pacX - x > 0)) {
           // while obstacle on the right
           if(ghostMap[x+1][y][0] != 1) {
           // move either up or down until obstacle is no longer on the right
             if((ghostMap[x][y-1][0] == 1) && (ableUp[i])) {  // go up
               pFx = centroX(x); 
               pFy -= vFantasmas[i];
             } else if ((ghostMap[x][y+1][0] == 1) && (ableDown[i])) { // go down
               ableUp[i] = false;
               pFx = centroX(x); 
               pFy += vFantasmas[i];
             } else {
             // go left until able to go either up or down
               if (ghostMap[x][y-1][0] == 1) {
                 pFx -= vFantasmas[i];
                 pFy = centroY(y);
                 
                 ableUp[i] = ghostMap[x][y-1][0] == 1;
                 ableDown[i] = ghostMap[x][y+1][0] == 1;
               }
             }
           }
           if (pacX - x > 0){ // go right
             if (ghostMap[x+1][y][0] == 1) {
               pFx += vFantasmas[i];
               pFy = centroY(y); 
               pFantasmas[i][2] = 4;
             }
           } else {
             obstacle[i] = false;
           } 
         } 
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

void moverPacman() { 
  px += vx;
  py += vy;
}

// diretion -> 0 for no change, 1 for change up (ip [if possible]), 2 for change down(ip),
// 3 for change left (ip) and 4 for change right (ip)
void orientarPacman(int direction) { 
  int x = (int)(Math.round((px + 0.5 - margemH/2)/tamanho));
  int y = (int)(Math.round((py + 0.5 - margemV/2)/tamanho));
         
  switch (direction) {
      
    case 1: // up 
      // adjust position for pacman going up
      x = (int)(Math.round((px + 0.5 + margemH*3.3)/tamanho)); 
      y = (int)(Math.round((py + 0.5 + margemV*3.3)/tamanho));
      
      // check for collisons
      if ((y > 1) && (get((int)centroX(x), (int)centroY(y-1)) != corObstaculos)) {
        vx = 0;
        vy = -1 * dificuldade;
        px = centroX(x);
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 2: //down
      if ((y < nLin) && (get((int)centroX(x), (int)centroY(y+1)) != corObstaculos)) {
        vx = 0;
        vy = 1 * dificuldade;
        px = centroX(x);
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 3: // left  
      // adjust position for pacman going left
      x = (int)(Math.round((px + 0.5 + margemH*3.3)/tamanho)); 
      y = (int)(Math.round((py + 0.5 + margemV*3.3)/tamanho));
      
      if ((x > 1) && (get((int)centroX(x-1), (int)centroY(y)) != corObstaculos)) {
        vy = 0;
        vx = -1 * dificuldade;
        py = centroY(y); 
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 4: // right    
      if ((x < nCol) && (get((int)centroX(x+1), (int)centroY(y)) != corObstaculos)) { //
        vy = 0;
        vx = 1 * dificuldade;
        py = centroY(y); 
      } else {
        vx = 0;
        vy = 0;
      }
      break;
  }

  // ajustar posicao se o pacman for para cima ou para a esquerda
  if (vx < 0 || vy < 0) { 
    x = (int)(Math.round((px + 0.5 + margemH*3.3)/tamanho)); 
    y = (int)(Math.round((py + 0.5 + margemV*3.3)/tamanho));
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

void desenharFantasmas() {
  
  for (int i = 0; i < fantasmas; i++) {
    switch (i) {
      case 0:
        fill(66, 197, 244);  // blue
        break;
      case 1:
        fill(244, 164, 66);  // orange
        break;
      case 2:
      fill(244, 75, 66);   // red
        break;
      case 3:
      fill(247, 173, 211); // pink
        break;
    }
    
    float raioFant = pRaio/3.0;
    pFantasmas[i][1] -= 3.5; // fazer o fantasma mais "alto" que o pacman
    
    // desenhar corpo do fantasma
    ellipse(pFantasmas[i][0], pFantasmas[i][1], pRaio, pRaio);
    rect(pFantasmas[i][0] - pRaio/2.0, pFantasmas[i][1], pRaio, pRaio/1.5);
    
    // desenhar cauda do fantasma, composta por 3 circulos
    ellipse(pFantasmas[i][0] - raioFant, pFantasmas[i][1] + pRaio/1.5, pRaio/3.0, pRaio/3.0);
    ellipse(pFantasmas[i][0], pFantasmas[i][1] + pRaio/1.5, pRaio/3.0, pRaio/3.0);
    ellipse(pFantasmas[i][0] + raioFant, pFantasmas[i][1] + pRaio/1.5, pRaio/3.0, pRaio/3.0);
        
    pFantasmas[i][1] += 3.5; // compensar o ajuste da altura do fantasma
  }
}

void comerPontos() {
  int x = (int)(Math.round((px + 0.5 - margemH)/tamanho));
  int y = (int)(Math.round((py + 0.5 - margemV/2)/tamanho));

  // adjust position for pacman going left or up
  if (vx < 0 || vy < 0) { 
    x = (int)(Math.round((px + 0.5 + margemH*3.3)/tamanho)); 
    y = (int)(Math.round((py + 0.5 + margemV*3.3)/tamanho));
  } else if (vx > 0) {
    x = (int)(Math.round((px + 0.5 - margemH/2)/tamanho + 0.23));
  }

  color c = get((int)centroX(x), (int)centroY(y));
  color white = color(255, 255 , 255);
  
  // se for comida (ponto branco), comer
  if (c == white) {  
    if (foodMap[x-1][y-1][0] == 1) {
      foodMap[x-1][y-1][0] = 0;
      
        // subir pontuacao
        pontuacao += 100 * (5/dificuldade);
    }
  }     
        


}

/* Desenha o pacman - recebe um boolean - verdadeiro 
   se o pacman anda da esquerda para a direita, falso
   se o pacman anda da direita para esquerda
*/
void desenharPacman() {
  fill(pacColor);
  ellipseMode(CENTER);
  noStroke();
  if (vy == 0) {
    if (vx > 0) {
      // arc between PI/4.0 and PI*7/4.0
      arc(px, py, pRaio, pRaio, map(abs(sin(px * PI/50)), 0, 1, PI/4.0, 0), map(abs(sin(px * PI/50)), 0, 1, PI*7/4.0, PI*2), PIE);
    } else {
      // arc betwwen -PI*3/4.0 and PI*3/4.0
      arc(px, py, pRaio, pRaio, map(abs(sin(px * PI/50)), 0, 1, -PI, -PI*3/4.0), map(abs(sin(px * PI/50)), 0, 1, PI, PI*3/4.0), PIE);
    }
  } else if (vy > 0) {
    // arc betwwen -PI*5/4.0 and PI/4.0
    arc(px, py, pRaio, pRaio, map(abs(sin(py * PI/50)), 0, 1, -PI*3/2.0, -PI*5/4.0), map(abs(sin(py * PI/50)), 0, 1, PI/2.0, PI/4.0), PIE);
  } else { // vy < 0
    // arc betwwen -PI/4.0 and PI*5/4.0
    arc(px, py, pRaio, pRaio, map(abs(sin(py * PI/50)), 0, 1, -PI/2.0, -PI/4.0), map(abs(sin(py * PI/50)), 0, 1, PI*3/2.0, PI*5/4.0), PIE);
  }
}


void desenharLabirinto () {

  // desenha a fronteira da área de jogo
  fill(0);
  stroke(80, 60, 200);
  strokeWeight(espacamento);
  rect(margemH, margemV, width - 2*margemH, height - 2*margemV);

  // Desenha obstáculos
  if (dificuldade == facil) { // easy map
    desenharObstaculo(2,2, 3, 1);
    desenharObstaculo(6,2, 3, 1);
    desenharObstaculo(10,2, 3, 1);
    desenharObstaculo(2,4, nCol-2, 1);
    desenharObstaculo(11,6, 3, 3);
    desenharObstaculo(7,6, 1, 1);
    desenharObstaculo(2,6, 3, 2);
    desenharObstaculo(2,9, 6, 1);
    desenharObstaculo(9,6, 1, 4);
  } /* else if (dificuldade == medio) {
    desenharObstaculo();
  } */ else {
    // hard map
    desenharObstaculo(2,2, nCol-9, 1);
    desenharObstaculo(8,2, nCol-8, 1); 
    desenharObstaculo(3,3, nCol-13, nLin-6);
    desenharObstaculo(5,4, nCol-13, nLin-6);
    desenharObstaculo(2,8, nCol-4, nLin-9);
    desenharObstaculo(1,4, nCol-13, nLin-7);
    desenharObstaculo(8,5, nCol-12, nLin-8);
    desenharObstaculo(1,10, nCol-1, nLin-9);
    desenharObstaculo(13,6, nCol-13, nLin-6);
    desenharObstaculo(11,6, nCol-11, nLin-9);
    desenharObstaculo(12,4, nCol-13, nLin-9); 
  }
  
}

/* Desenha um obstáculo interno de um labirinto:
   x: índice da célula inicial segundo eixo dos X - gama (1..nCol) 
   y: índice da célula inicial segundo eixo dos Y - gama (1..nLin)
   numC: nº de colunas (células) segundo eixo dos X (largura do obstáculo)
   numL: nº de linhas (células) segundo eixo dos Y (altura do obstáculo) 
*/
void desenharObstaculo(int x, int y, int numC, int numL) {
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

/*
Desenhar pontos nas células vazias (que não fazem parte de um obstáculo). 
Esta função usa a cor de fundo no ecrã para determinar se uma célula está vazia ou se faz parte de um obstáculo.
*/
void desenharPontos() {
  ellipseMode(CENTER);
  fill(255);
  noStroke();

 
  // if on array, draw
  for (int i = 0; i < nCol; i++) {
    for (int j = 0; j < nLin; j++) {
      if (foodMap[i][j][0] == 1) {
        ellipse(centroX(i+1), centroY(j+1), pRaio/2, pRaio/2);
      }
    }
  }
}

// transformar o índice de uma célula em coordenada no ecrã
float centroX(int col) {
  return margemH + (col - 0.5) * tamanho;
}

// transformar o índice de uma célula em coordenada no ecrã
float centroY(int lin) {
  return margemV + (lin - 0.5) * tamanho;
}



// win game
// menu (also displays scores)
// map for medium dificulty
// eat ghosts cheat code