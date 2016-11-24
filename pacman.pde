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

List<float[]> pontos = new ArrayList<float[]>();

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
  
  
  // o codigo abaixo corre uma vez para definir o ArrayList de Pontos
  desenharLabirinto();  
  // Insere um ponto nas células vazias
  for(int i=1; i<=nCol; i++) {
    for(int j=1; j<=nLin; j++) {
      float[] coords = new float[2];
      coords[0] = centroX(i); // = x
      coords[1] = centroY(j); // = y
      color c = get((int)coords[0], (int)coords[1]);
      if(c != corObstaculos) {
        pontos.add(coords);
        }       
      }      
    }
  
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

// sets up two small but essential variables in order to start the game
void startGame() {
  vx = 1 * dificuldade;
  gameStarted = true;
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
  
  switch (direction) {
    case 1: // up
      vx = 0;
      vy = -1 * dificuldade;
      break;
    case 2: //down
      vx = 0;
      vy = 1 * dificuldade;
      break;
    case 3: // left
      vy = 0;
      vx = -1 * dificuldade;
      break;
    case 4: // right
      vy = 0;
      vx = 1 * dificuldade;
      break;
  }

  // detetar margens
  if(px > centroX(nCol)) {
    vx = -vx;
  } else if(px < centroX(1)) {
    vx = -vx;
  }
  if(py > centroY(nLin)) {
    vy = -vy;
  } else if(py < centroY(1)) {
    vy = -vy;
  }
  
  // detetar obstaculos
  float[] extremesX = {px, px-pRaio/2, px+pRaio/2};
  float[] extremesY = {py, py-pRaio/2, py+pRaio/2};
  for(int i = 0; i < 3; i++) { // 3 = nr de elementos em cada array
    for(int j = 0; j < 3; j++) {
      color c = get((int)extremesX[i], (int)extremesY[j]);
      if(c == corObstaculos && ((vx != 0) || (vy != 0))) {
        vx = 0;
        vy = 0;
      }
    }
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
  float[] extremesX = {px, px-pRaio/2, px+pRaio/2};
  float[] extremesY = {py, py-pRaio/2, py+pRaio/2};
  for(int i = 0; i < 3; i++) { // 3 = nr de elementos em cada array
    for(int j = 0; j < 3; j++) {
      color c = get((int)extremesX[i], (int)extremesY[j]);
      color white = color(255, 255 , 255);
      
      if (c == white) {  
        
        for (int k = 0; k < pontos.size(); k++) {
          //float[] coords = pontos.get(k);
          if(((pontos.get(k)[0] - extremesX[i]) <= pRaio/4) && ((pontos.get(k)[1] - extremesY[i]) <= pRaio/4)) {
            pontos.remove(k);
          }
        }     
        
        // subir pontuacao
        
      }
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
  //fill(0);
  //triangle(px, py, px+pRaio/1.828427125, py-pRaio/1.828427125, px+pRaio/1.828427125, py+pRaio/1.828427125);
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

 
  // if on arraylist, draw
  for (float[] temp : pontos) {
    fill(255);
    ellipse(temp[0], temp[1], pRaio/2, pRaio/2);
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