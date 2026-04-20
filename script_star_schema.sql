-- Criação Schema Dimensional
CREATE DATABASE IF NOT EXISTS universidade_dimensional;
USE universidade_dimensional;

-- Dimensão Professor: Atributos descritivos do docente
CREATE TABLE Dim_Professor (
    id_professor INT PRIMARY KEY,
    nome_professor VARCHAR(100) NOT NULL,
    titulo VARCHAR(50),
    data_admissao DATE
);

-- Dimensão Departamento: Atributos do departamento e seu coordenador
CREATE TABLE Dim_Departamento (
    id_departamento INT PRIMARY KEY,
    nome_departamento VARCHAR(100) NOT NULL,
    campus VARCHAR(50) NOT NULL,
    nome_coordenador VARCHAR(100)
);

-- Dimensão Curso: Atributos descritivos do curso
CREATE TABLE Dim_Curso (
    id_curso INT PRIMARY KEY,
    nome_curso VARCHAR(100) NOT NULL,
    modalidade VARCHAR(50) -- Ex: Presencial, EAD
);

-- Dimensão Disciplina: Atributos da disciplina e seus pré-requisitos achatados
CREATE TABLE Dim_Disciplina (
    id_disciplina INT PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria_base INT,
    lista_pre_requisitos TEXT -- Achatamento das tabelas N:M de pré-requisitos para evitar Snowflake
);

-- Dimensão Data/Calendário: Para análise temporal (Semestres e Anos)
CREATE TABLE Dim_Data (
    id_data INT PRIMARY KEY, -- Formato YYYYMMDD ou Sequencial
    data_completa DATE NOT NULL,
    ano INT NOT NULL,
    semestre INT NOT NULL,
    mes INT NOT NULL,
    nome_mes VARCHAR(20)
);

-- Tabela Fato: Centraliza o evento de alocação de um professor a uma disciplina
-- Granularidade: Uma linha por Professor, Disciplina, Curso e Semestre.
CREATE TABLE Fato_Alocacao_Professor (
    id_fato INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Chaves Estrangeiras (FK) para as Dimensões
    sk_professor INT NOT NULL,
    sk_departamento INT NOT NULL,
    sk_curso INT NOT NULL,
    sk_disciplina INT NOT NULL,
    sk_data INT NOT NULL,
    
    -- Métricas (Fatos)
    quantidade_horas INT NOT NULL, -- Carga horária específica desta alocação
    
    -- Restrições de Integridade
    CONSTRAINT fk_fato_professor FOREIGN KEY (sk_professor) REFERENCES Dim_Professor(id_professor),
    CONSTRAINT fk_fato_departamento FOREIGN KEY (sk_departamento) REFERENCES Dim_Departamento(id_departamento),
    CONSTRAINT fk_fato_curso FOREIGN KEY (sk_curso) REFERENCES Dim_Curso(id_curso),
    CONSTRAINT fk_fato_disciplina FOREIGN KEY (sk_disciplina) REFERENCES Dim_Disciplina(id_disciplina),
    CONSTRAINT fk_fato_data FOREIGN KEY (sk_data) REFERENCES Dim_Data(id_data)
);

-- Índices para otimização de performance em consultas dimensionais
CREATE INDEX idx_fato_professor ON Fato_Alocacao_Professor(sk_professor);
CREATE INDEX idx_fato_departamento ON Fato_Alocacao_Professor(sk_departamento);
CREATE INDEX idx_fato_data ON Fato_Alocacao_Professor(sk_data);
