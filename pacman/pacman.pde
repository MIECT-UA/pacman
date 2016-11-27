import java.util.*;
import java.io.*;


// Parâmetros do labirinto
int nCol, nLin;          // nº de linhas e de colunas
int tamanho = 50;        // tamanho (largura e altura) das células do labirinto  
int espacamento = 2;     // espaço livre emtre células
float margemV, margemH;  // margem livre na vertical e na horizontal para assegurar que as células são quadrangulares
color corObstaculos =  color(100, 0 , 128);      // cor de fundo dos obstáculos

// Posicao e tamanho do Pacman
float px, py, pRaio;

//velocidade na horizontal e vertical do Pacman
float vx, vy; 
 
// TODO - splash screen + dificulty selector
int fantasmas = 4;
float[][] pFantasmas = new float[fantasmas][3];
float[] vFantasmas = {0.9, 1, 1.05, 1.13};
int[][][] ghostMap;
boolean[] obstacle = {false, false, false, false};
boolean[] ableUp = {true, true, true, true}, ableDown = {true, true, true, true}, 
          ableLeft = {true, true, true, true}, ableRight = {true, true, true, true};


int[][][] foodMap;

boolean gameStarted = false;
float dificuldade;
int pontuacao = 0;


// alinhar pacman e fantasmas
// calcular high score e guardar num ficheiro
// desenhar campo

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
 
  frameRate(60);
  
}

void draw(){
  background(0);
  
  // SPLASH SCREEN + SELECIONAR DIFICULDADE
  if (!gameStarted) {
    String start = "Escolhe um nível de dificuldade:";
    fill(178);
    textSize(32);
    text(start, 100, 100);
    
    text("Fácil", 100, 300); 
    text("Médio", 300, 300); 
    text("Difícil", 500, 300); 

    
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
      orientarPacman(4);
    }
  }
}

void mouseClicked() {
  if (!gameStarted) {
    if((mouseX >= 50) && (mouseX <= 250) && (mouseY >= 250) && (mouseY <= 350)) {
      // facil
      dificuldade = 2;
      startGame();
    } else if ((mouseX >= 250) && (mouseX <= 450) && (mouseY >= 250) && (mouseY <= 350)) {
      // medio
      dificuldade = 3.5;
      startGame();
    } else if ((mouseX >= 450) && (mouseX <= 650) && (mouseY >= 250) && (mouseY <= 350)) {
      // dificil
      dificuldade = 5;
      startGame();
    }
  }
}

// sets up several variables in order to start the game
void startGame() {
  
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
  
  vx = 1 * dificuldade;
  
  // run all the functions that make up the game one time before draw does,
  // in order to set up the food
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
  
  gameStarted = true; 
  
  desenharPontos();
  desenharPacman();
  desenharFantasmas();
  comerPontos();
  orientarPacman(0);
  moverPacman();
  moverFantasmas();
  
       
}

void gameOver() throws IOException {
  File highscores = new File("highscores.txt");
  PrintWriter pw = new PrintWriter(new FileOutputStream(highscores), true);
  pw.append(String.valueOf(pontuacao));
  pw.close();
  
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
      int y = (int)Math.round((pFy + 0.5 - margemV/2)/tamanho);
     
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
     
     
     text(x, 100*(i+1), 200);
     text(y, 100*(i+1), 300);
     
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
         if ((pacX == x) && (pacY == y)) {
           try {
            gameOver();
          } catch (IOException e) {
            System.err.println("Caught IOException: " + e.getMessage());
          }
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
    vx = 0; // -vx
    px = centroX(x); 
  } else if((py > centroY(nLin)) || (py < centroY(1))) {
    vy = 0; // -vy
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
  int x = (int)(Math.round((px + 0.5 - margemH/2)/tamanho));
  int y = (int)(Math.round((py + 0.5 - margemV/2)/tamanho));

  // adjust position for pacman going left or up
  if (vx < 0 || vy < 0) { 
    x = (int)(Math.round((px + 0.5 + margemH*3.3)/tamanho)); 
    y = (int)(Math.round((py + 0.5 + margemV*3.3)/tamanho));
  }
 
  color c = get((int)centroX(x), (int)centroY(y));
  color white = color(255, 255 , 255);
      
  if (c == white) {  
    if (foodMap[x-1][y-1][0] == 1) {
      foodMap[x-1][y-1][0] = 0;
      
        // subir pontuacao
        pontuacao += 100;
    }
  }     
        


}

/* Desenha o pacman - recebe um boolean - verdadeiro 
   se o pacman anda da esquerda para a direita, falso
   se o pacman anda da direita para esquerda
*/
void desenharPacman() {
  fill(232, 239, 40);
  //ellipseMode(CENTER);
  //noStroke();
  if (vy == 0) {
    if (vx > 0) {
      arc(px, py, pRaio, pRaio, PI/4.0, PI*7/4.0, PIE);
    } else {
      arc(px, py, pRaio, pRaio, -PI*3/4.0, PI*3/4.0, PIE);
    }
  } else if (vy > 0) {
    arc(px, py, pRaio, pRaio, -PI*5/4.0, PI/4.0, PIE);
  } else { // vy < 0
    arc(px, py, pRaio, pRaio, -PI/4.0, PI*5/4.0, PIE);
  }
}

void desenharLabirinto () {

  // desenha a fronteira da área de jogo
  fill(0);
  stroke(80, 60, 200);
  strokeWeight(espacamento);
  rect(margemH, margemV, width - 2*margemH, height - 2*margemV);

  // Desenha obstáculos
  /*desenharObstaculo(2,2, 3, 1);
  desenharObstaculo(6,2, 3, 1);
  desenharObstaculo(10,2, 3, 1);
  desenharObstaculo(2,4, nCol-2, 1);
  desenharObstaculo(10,6, 4, 3);
  desenharObstaculo(7,6, 1, 1);
  desenharObstaculo(2,6, 3, 2); */
  
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
  //stroke(0);
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



/*

else if ((y > 1) && (get((int)centroX(x), (int)centroY(y-1)) != corObstaculos)) { 
         // move up is possible - this else if is only reached if pacman is directly above ghost
         pFx = centroX(x); 
         pFy -= vFantasmas[i];
       } 

*/

// win game
// lose game
// save score
// menu (also displays scores)