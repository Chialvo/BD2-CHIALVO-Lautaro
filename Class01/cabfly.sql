DROP DATABASE IF EXISTS Cabfly; 
CREATE DATABASE IF NOT EXISTS Cabfly;
USE Cabfly;

CREATE TABLE Aeronave (
    idAeronave INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE EstadoVuelo (
    idEstadoVuelo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE CompaniaAerea (
    idCompaniaAerea INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE ServicioComida (
    idServicioComida INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE Ciudad (
    idCiudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE Aeropuerto (
    idAeropuerto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    idCiudad INT,
    descripcion VARCHAR(255),
    FOREIGN KEY (idCiudad) REFERENCES Ciudad(idCiudad)
);

CREATE TABLE Vuelo (

    numVuelo INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    duracion INT,
    distancia INT,
    idAeropuertoSalida INT,
	idEstadoVuelo INT,
    idCompaniaAerea INT,
    idServicioComida INT,
    horaSalida DATETIME,
    idAeropuertoLlegada INT,
    horaLlegada DATETIME,
    idAeronave INT,
    
    FOREIGN KEY (idEstadoVuelo) REFERENCES EstadoVuelo(idEstadoVuelo),
    FOREIGN KEY (idCompaniaAerea) REFERENCES CompaniaAerea(idCompaniaAerea),
    FOREIGN KEY (idServicioComida) REFERENCES ServicioComida(idServicioComida),
    FOREIGN KEY (idAeropuertoSalida) REFERENCES Aeropuerto(idAeropuerto),
    FOREIGN KEY (idAeropuertoLlegada) REFERENCES Aeropuerto(idAeropuerto),
    FOREIGN KEY (idAeronave) REFERENCES Aeronave(idAeronave)
);

CREATE TABLE EstadoAsiento (
    idEstadoAsiento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE Asiento (
    idAsiento INT AUTO_INCREMENT PRIMARY KEY,
    fila INT,
    numero INT,
    idEstadoAsiento INT,
    FOREIGN KEY (idEstadoAsiento) REFERENCES EstadoAsiento(idEstadoAsiento)
);

CREATE TABLE Pasaporte (
    idPasaporte INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE Pasajero (
    idPasaporte INT,
    numDocumento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    apellido VARCHAR(255),
    numTelefonoContacto INT,
    correoElectronico VARCHAR(255),
    FOREIGN KEY (idPasaporte) REFERENCES Pasaporte(idPasaporte)
);

CREATE TABLE Reserva (
    numReserva INT AUTO_INCREMENT PRIMARY KEY,
    numDocumento INT,
    numVuelo INT,
    idAsiento INT,
    costo INT,
	FOREIGN KEY (numDocumento) REFERENCES Pasajero(numDocumento),
    FOREIGN KEY (numVuelo) REFERENCES Vuelo(numVuelo),
    FOREIGN KEY (idAsiento) REFERENCES Asiento(idAsiento)
);
   