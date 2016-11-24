import java.util.ArrayList;
import java.util.List;


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
float[][] pFantasmas = new float[fantasmas][2];

int[][][] foodMap;

boolean gameStarted = false;
float dificuldade;
int pontuacao;


// alinhar pacman e fantasmas
// calcular high score e guardar num ficheiro
// impedir colisoes com obstaculos (rebounce)
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
  
  // Inicializar o Pacman
  px = centroX(1);
  py = centroY(1);
  pRaio = tamanho / 2;                                                            /// pacman size //(tamanho - espacamento) / 1.5
  
  foodMap = new int[nCol][nLin][1];
  
  // Inicializar os fantasmas
  pFantasmas[0][0] = centroX(nLin/2);
  pFantasmas[0][1] = centroY(nCol/2);
  
  pFantasmas[1][0] = centroX(1);
  pFantasmas[1][1] = centroY(1);
  
  pFantasmas[2][0] = centroX(nLin/2 + 2);
  pFantasmas[2][1] = centroY(nCol/2);
  
  pFantasmas[3][0] = centroX(nLin/2 + 1);
  pFantasmas[3][1] = centroY(nCol/2 - 1);
  
  //~//specifies speeds in X and Y directions
  //~vx = 0;
  //~vy = 0;

 
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

// sets up three small but essential variables in order to start the game
void startGame() {
  vx = 1 * dificuldade;
  gameStarted = true;
  
  // run all the functions that make up the game one time before draw does,
  // in order to set up the food
  desenharLabirinto();
    // set up foodMap
  for (int i = 0; i < nCol; i++) {
    for (int j = 0; j < nLin; j++) {
      color c = get((int)centroX(i+1), (int)centroY(j+1));
      if(c != corObstaculos) {
          foodMap[i][j][0] = 1;
        } else {
          foodMap[i][j][0] = 0;
        }
      }
  } 
  desenharPontos();
  desenharPacman();
  desenharFantasmas();
  comerPontos();
  orientarPacman(0);
  moverPacman();
  moverFantasmas();
  
       
}

void moverFantasmas() {

}

void moverPacman() { 
  px += vx;
  py += vy;
}

// diretion -> 0 for no change, 1 for change up (ip [if possible]), 2 for change down(ip),
// 3 for change left (ip) and 4 for change right (ip)
void orientarPacman(int direction) { 
   int x = (int)Math.round((px + 0.5)/tamanho);
   int y = (int)Math.round((py + 0.5)/tamanho);
         
  switch (direction) {
      
    case 1: // up 
      // check for collisons
      if ((y > 1) && (get((int)centroX(x), (int)centroY(y-1)) != corObstaculos)) { // 
        vx = 0;
        vy = -1 * dificuldade;
        px = centroX(x);
      } else { 
        vx = 0;
        vy = 0;
      }
      break;
    case 2: //down
      if ((y < nLin) && (get((int)centroX(x), (int)centroY(y+1)) != corObstaculos)) { // 
        vx = 0;
        vy = 1 * dificuldade;
        px = centroX(x);
      } else {
        vx = 0;
        vy = 0;
      }
      break;
    case 3: // left  
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

  // colisao com margens
  if((px > centroX(nCol)) || (px < centroX(1))) {
    vx = 0; // -vx
    px = centroX(x); 
  } if((py > centroY(nLin)) || (py < centroY(1))) {
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
  
  // prob with left and up
  
  int x = (int)Math.round((px + 0.5)/tamanho);
  int y = (int)Math.round((py + 0.5)/tamanho);
 
  color c = get((int)centroX(x), (int)centroY(y));
  color white = color(255, 255 , 255);
      
  if (c == white) {  
    if (foodMap[x-1][y-1][0] == 1) {
      foodMap[x-1][y-1][0] = 0;
      
        // subir pontuacao
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
  desenharObstaculo(2,2, nCol-2, 1);
  desenharObstaculo(2,4, nCol-2, nLin-4);
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
  stroke(0);
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