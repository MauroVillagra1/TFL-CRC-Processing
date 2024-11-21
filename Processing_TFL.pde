import processing.serial.*;

Serial myPort;  // Objeto para la comunicación serial
String receivedMessage = "";  // Mensaje recibido
String userInput = "";  // Entrada del usuario
boolean isWaitingForWord = true;
boolean isWaitingForOption = false;
boolean isWaitingForResult = false;
int selectedOption = 0;
float scrollOffset = 0;  // Para manejar el scroll
int rightPaneWidth = 400;  // Ancho del panel derecho
boolean aux = false;
boolean aux2 = false;

void setup() {
  size(1000, 1000);  // Tamaño de la ventana

  // Configurar puerto serial
  println(Serial.list());  // Mostrar los puertos disponibles
  myPort = new Serial(this, "COM4", 9600);  // Ajustar al puerto correcto
  myPort.clear();

  // Dibujar interfaz inicial
  drawLeftPane("");
  drawRightPane("Esperando entrada...");
}

void draw() {

  if (myPort.available() > 0) {
    String inData = myPort.readStringUntil('\n');  // Leer datos del puerto serial
    if (inData != null) {
      inData = inData.trim();
      if (isWaitingForResult) {
        receivedMessage += inData + "\n";
        drawRightPane(receivedMessage);
      }
    }
  }
}

void keyPressed() {
  if (isWaitingForWord || isWaitingForOption) {
    if (key == '\n') {  // Cuando el usuario presiona Enter
      if (isWaitingForWord) {
        if (!userInput.isEmpty()) {
          myPort.write(userInput + "\n");  // Enviar la palabra al Arduino
          isWaitingForWord = false;
          isWaitingForOption = true;
          userInput = "";  // Limpiar entrada del usuario
          delay(1000);
          drawLeftPane("Seleccione una opción:\n1. CRC-12\n2. CRC-16\n3. CRC-CCITT\n4. CRC-Prueba\n5. CRC-Personalizado");
        } else {
          drawLeftPane("Ingrese una palabra válida:");
        }
      } else if (isWaitingForOption) {
        try {
          selectedOption = Integer.parseInt(userInput);
          if (selectedOption >= 1 && selectedOption <= 7) {
              myPort.write(selectedOption + "\n");  // Enviar la opción seleccionada
              isWaitingForOption = false;
              isWaitingForResult = true;
              drawRightPane("Procesando...");
            
          } else {
            drawLeftPane("Opción no válida. Intente de nuevo:\n1. CRC-12\n2. CRC-16\n3. CRC-CCITT\n4. CRC-Prueba\n5. CRC-Personalizado");
          }
        } catch (Exception e) {
          drawLeftPane("Opción no válida. Intente de nuevo:\n1. CRC-12\n2. CRC-16\n3. CRC-CCITT\n4. CRC-Prueba\n5. CRC-Personalizado");
        }
        userInput = "";  // Limpiar entrada del usuario
      }
    } else if (key == BACKSPACE) {
      if (userInput.length() > 0) userInput = userInput.substring(0, userInput.length() - 1);
    } else {
      userInput += key;
    }
    drawLeftPane(userInput);
  }
}

void drawLeftPane(String message) {
  fill(240); // Color de fondo del panel izquierdo
  rect(0, 0, width - rightPaneWidth, height);

  fill(0); // Color del texto
  float textX = 10;
  float textY = 20;
  if(aux==true){
    message = "";
  }
  else if(aux2==true){
    message = "";
  }

  textSize(16); // Tamaño de la fuente

  // Posición inicial del texto
  

  // Dibujar el mensaje principal
  text(message, textX, textY);
  if (isWaitingForWord) {
     String[] options = {
       "Ingrese una palabra: " + userInput
     };
     aux2=true;
      for (String option : options) {
      text(option, textX, textY);
            textY += 10 * 1.5;

    }
  }
  // Si se está esperando la selección de una opción
  if (isWaitingForOption) {
    String[] options = {
      "Seleccion una opcion: ",
      "",
      "1. CRC-12",
      "2. CRC-16",
      "3. CRC-CCITT",
      "4. CRC-3",
      "5. CRC-4",
      "6. CRC-5",
      "7. CRC-6",
      "",
    "Escriba su opción aquí: " + userInput 
    };
    aux=true;

    // Dibujar cada opción en una línea diferente
    for (String option : options) {
      text(option, textX, textY);
            textY += 10 * 1.5;

    }
  }
 if(isWaitingForResult==true){
     textSize(20);

text("Su resultado Aparacera en pantalla -->", textX, textY);

 }
 
}

void drawRightPane(String message) {
  fill(240);
  rect(width - rightPaneWidth, 0, rightPaneWidth, height);  // Limpiar el panel derecho
  fill(0);
  textSize(14);
 if(isWaitingForResult==true){  textSize(14);

 }
  textAlign(LEFT, TOP);
  text("Tramas y Mensajes Recibidos:", width - rightPaneWidth + 20, 20);

  // Mostrar con soporte para scroll
  pushMatrix();
  translate(0, -scrollOffset);
  text(message, width - rightPaneWidth + 20, 60, rightPaneWidth - 40, height * 2);  // Multiplica height si esperas mucho contenido
  popMatrix();
}

// Detectar desplazamiento del mouse para scroll
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scrollOffset += e * 20;  // Ajusta la velocidad del scroll
  scrollOffset = constrain(scrollOffset, 0, max(0, textAscent() * receivedMessage.length() - height));
} 
