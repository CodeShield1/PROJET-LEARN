CREATE DATABASE bibliotheque;
USE bibliotheque;


CREATE TABLE rayons (
    id_rayon INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL   
);


INSERT INTO rayons (nom) VALUES
('Informatique'),
('Mathématiques'),
('Sciences'),
('Littérature'),
('Histoire'),
('Économie'),
('Philosophie');


CREATE TABLE ouvrages (
    id_ouvrage INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    date_publication DATE NOT NULL,
    id_rayon INT NOT NULL,
    FOREIGN KEY (id_rayon) REFERENCES rayons(id_rayon)
);


SELECT * FROM ouvrages;

ALTER TABLE ouvrages
ADD annee_publication INT ;

UPDATE ouvrages
SET annee_publication = YEAR(date_publication);




INSERT INTO ouvrages (titre, date_publication, id_rayon) VALUES
('Apprendre SQL',       '2022-01-10', 1),  
('Algorithmique',       '2019-09-01', 2), 
('Physique générale',   '2020-04-12', 3),
('Les Misérables',      '1862-01-01', 4), 
('Histoire du Maroc',   '2018-06-20', 5),
('Microéconomie',       '2021-03-11', 6), 
('Introduction à Kant', '2017-09-05', 7);




CREATE TABLE auteurs (
    id_auteur INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255) NOT NULL
);


INSERT INTO auteurs (nom, prenom) VALUES
('Benali', 'Omar'),
('El Amrani', 'Youssef'),
('Alaoui', 'Hassan'),
('Bennani', 'Khadija'),
('Idrissi', 'Salma'),
('Fassi', 'Mehdi'),
('Zerouali', 'Nadia');


CREATE TABLE lecteurs (
    id_lecteur INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255) NOT NULL,
    telephone VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    CIN VARCHAR(255) NOT NULL UNIQUE
    );




INSERT INTO lecteurs (nom, prenom, telephone, email, CIN) VALUES
('alae', 'Omar', '0612345678', 'omar@gmail.com', 'AA111111'),
('Alaoui', 'Hassan', '0623456789', 'hassan@gmail.com', 'BB222222'),
('Idrissi', 'Salma', '0634567890', 'salma@gmail.com', 'CC333333'),
('Bennani', 'Khadija', '0645678901', 'khadija@gmail.com', 'DD444444'),
('Fassi', 'Mehdi' , '0656789012', 'mehdi@gmail.com', 'EE555555'),
('Zerouali', 'Nadia', '0667890123', 'nadia@gmail.com', 'FF666666'),
('El Amrani', 'Youssef', '0678901234', 'youssef@gmail.com', 'GG777777');
 



CREATE TABLE auteurs_ouvrages (
    id_auteur INT NOT NULL,
    id_ouvrage INT NOT NULL,
    PRIMARY KEY (id_auteur, id_ouvrage),
    FOREIGN KEY (id_auteur) REFERENCES auteurs(id_auteur),
    FOREIGN KEY (id_ouvrage) REFERENCES ouvrages(id_ouvrage)
);




INSERT INTO auteurs_ouvrages (id_auteur, id_ouvrage) VALUES
(1, 1),
(1, 2),
(2, 1), 
(3, 3), 
(4, 4), 
(5, 5), 
(6, 6), 
(7, 7); 




CREATE TABLE emprunts (
    id_emprunt INT AUTO_INCREMENT PRIMARY KEY,
    id_lecteur INT NOT NULL,
    id_ouvrage INT NOT NULL,
    date_emprunt DATE NOT NULL,
    date_retour_prevu DATE , 
    date_retour_reelle DATE,
    FOREIGN KEY (id_lecteur) REFERENCES lecteurs(id_lecteur),
    FOREIGN KEY (id_ouvrage) REFERENCES ouvrages(id_ouvrage)
);





INSERT INTO emprunts
(id_lecteur, id_ouvrage, date_emprunt, date_retour_prevu, date_retour_reelle)
VALUES
(1, 3, '2024-01-05', '2024-01-15', '2024-01-14'),
(2, 1, '2024-01-12', '2024-01-22', NULL),
(3, 5, '2024-02-01', '2024-02-10', '2024-02-09'),
(4, 2, '2024-02-08', '2024-02-18', NULL),
(5, 7, '2024-02-20', '2024-03-01', '2024-02-28'),
(6, 4, '2024-03-05', '2024-03-15', NULL),
(7, 6, '2024-03-18', '2024-03-28', '2024-03-27');

SELECT * FROM emprunts;

CREATE TABLE personnel (
    id_personnel INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    id_chef INT NULL,
    cin VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_chef) REFERENCES personnel(id_personnel)
);




SELECT * FROM personnel;

INSERT INTO personnel (nom, prenom, email, id_chef ,cin) VALUES
('alae', 'Omar', 'omar@gmail.com', NULL,'AA111111'),
('Alaoui', 'Hassan', 'hassan@gmail.com', 1,'BB222222'),
('Idrissi', 'Salma', 'salma@gmail.com', 1   ,'CC333333'),
('Bennani', 'Khadija', 'khadija@gmail.com', 2 ,'DD444444'),
('Fassi', 'Mehdi', 'mehdi@gmail.com', 2 ,'EE555555'),
('Zerouali', 'Nadia', 'nadia@gmail.com', 2 ,'FF666666'),
('El Amrani', 'Youssef', 'youssef@gmail.com', 1,'GG777777');




                         --realisation--

        --1. Contraintes d'unicité

--l’adresse email d’un lecteur
ALTER TABLE lecteurs
ADD CONSTRAINT uq_email_lecteur UNIQUE (email);


--le numéro CIN d’un membre du personnel
ALTER TABLE lecteurs
ADD CONSTRAINT uq_cin_personnel  UNIQUE (cin);


--la combinaison  titre + auteur + année de publication d’un ouvrage
ALTER TABLE ouvrages
ADD CONSTRAINT uq_titre_annee UNIQUE (titre, annee_publication);

ALTER TABLE auteurs_ouvrages
ADD CONSTRAINT uq_auteur_ouvrage UNIQUE (id_auteur, id_ouvrage);





         --2. Contraintes de validation à ajouter

--l’année de publication d’un ouvrage doit être comprise entre 1862 et l’année courante
ALTER TABLE ouvrages
ADD CONSTRAINT chk_annee_publication
CHECK (
    annee_publication BETWEEN 1862 AND 2025
);


--Numéro de téléphone ≥ 10 caractères
ALTER TABLE lecteurs
ADD CONSTRAINT chk_telephone_length
CHECK (LENGTH(telephone) >= 10);



ALTER TABLE emprunts
ADD CONSTRAINT chk_date_emprunt
CHECK (date_emprunt <= CURDATE());



-- durée prévue d’emprunt ≤ 30 jours
ALTER TABLE emprunts
ADD CONSTRAINT chk_duree_emprunt
CHECK (DATEDIFF( date_retour_prevu, date_emprunt) <= 30);


-- le nom d’un rayon doit être parmi une liste prédéfinie
ALTER TABLE rayons
ADD CONSTRAINT chk_nom_rayon
CHECK (nom IN ('Informatique','Mathématiques','Sciences','Littérature','Histoire','Économie','Philosophie'));





-- Trigger pour limiter le nombre d'emprunts en cours à 3 par lecteur
CREATE TRIGGER trg_max_3_emprunts
BEFORE INSERT ON emprunts
FOR EACH ROW
BEGIN
    DECLARE nb_emprunts INT;

    SELECT COUNT(*) INTO nb_emprunts
    FROM emprunts
    WHERE id_lecteur = NEW.id_lecteur
      AND date_retour_effective IS NULL;

    IF nb_emprunts >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ce lecteur a déjà 3 emprunts en cours';
    END IF;
END ;

        |  |
        |  |
       \    /
        \  /
         \/  

CREATE TRIGGER trg_max_3_emprunts
BEFORE INSERT ON emprunts
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM emprunts
        WHERE id_lecteur = NEW.id_lecteur
          AND date_retour_effective IS NULL
        LIMIT 3
        OFFSET 2
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ce lecteur a déjà 3 emprunts en cours';
    END IF;
END$$


----------------------------------------------------------------------------

--interdire l'emprunt d'un ouvrage déjà emprunté et non retourné
CREATE TRIGGER  trg_ouvrage_deja_emprunte
BEFORE INSERT ON emprunts
FOR EACH ROW 
BEGIN
  DECLARE deja_emprunte INT;
  SELECT COUNT(*) INTO deja_emprunte
  FROM emprunts
  WHERE id_ouvrage = NEW.id_ouvrage
    AND date_retour_reelle IS NULL;

  IF deja_emprunte > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cet ouvrage est déjà emprunté';
  END IF;
END;

        |  |
        |  |
       \    /
        \  /
         \/        

IF EXISTS (
   SELECT 1
   FROM emprunts
   WHERE id_ouvrage = NEW.id_ouvrage
     AND date_retour_reelle IS NULL
) THEN
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT = 'Cet ouvrage est déjà emprunté';
END IF;   3awed code kamel b had noskha  






--vérifier lors de la mise à jour que la date de retour effective est supérieure ou égale à la date d’emprunt
CREATE TRIGGER trg_verif_date_retour
BEFORE UPDATE ON emprunts
FOR EACH ROW
BEGIN
    IF NEW.date_retour_reelle IS NOT NULL
       AND NEW.date_retour_reelle < OLD.date_emprunt THEN
       
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date de retour invalide : elle est antérieure à la date d’emprunt';
    END IF;
END;




--interdire la suppression d’un ouvrage qui est actuellement emprunté
CREATE TRIGGER trg_interdire_suppression_ouvrage_emprunte
BEFORE DELETE ON ouvrages
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM emprunts
        WHERE id_ouvrage = OLD.id_ouvrage
          AND date_retour_reelle IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer cet ouvrage : il est actuellement emprunté';
    END IF;
END;


















--protype--


--Affcher tous les rayons de la bibliothèque.
SELECT * FROM rayons;



--Afficher le nom et le prénom de tous les auteurs.
SELECT nom , prenom FROM auteurs ;



--Afficher le titre et l’année de publication de tous les ouvrages.
SELECT titre , date_publication FROM ouvrages;




--Afficher le nom, le prénom et l’email de tous les lecteurs.
SELECT nom , prenom , email FROM lecteurs;




--Afficher les ouvrages publiés après l’année 1862.
SELECT date_publication 
FROM ouvrages 
WHERE date_publication>'1862-01-01';




--Afficher les lecteurs dont le nom commence par la lettre B.
SELECT nom FROM auteurs 
WHERE nom LIKE 'B%';




--Afficher les ouvrages triés par année de publication (du plus récent au plus ancien).
SELECT date_publication 
FROM ouvrages
ORDER BY date_publication DESC;



--Afficher les emprunts dont la date de retour effective est nulle.
SELECT id_ouvrage, date_retour_prevu 
FROM emprunts
WHERE date_retour_reelle IS NULL; 



--Afficher la liste des ouvrages avec le nom de leur rayon.
SELECT ouvrages.id_ouvrage, ouvrages.titre, rayons.nom 
FROM ouvrages
INNER JOIN rayons ON ouvrages.id_rayon = rayons.id_rayon;




--Afficher les titres des ouvrages ainsi que le nom et le prénom de leurs auteurs.
SELECT   ouvrages.titre , lecteurs.nom , lecteurs.prenom
FROM emprunts
INNER JOIN ouvrages ON emprunts.id_ouvrage = ouvrages.id_ouvrage
INNER JOIN lecteurs ON emprunts.id_lecteur = lecteurs.id_lecteur;





--Afficher les lecteurs ayant effectué au moins un emprunt.
SELECT  nom
FROM lecteurs 
WHERE EXISTS (
    SELECT 1
     FROM emprunts 
    WHERE emprunts.id_lecteur = lecteurs.id_lecteur
);





--Afficher le nombre d’ouvrages par rayon.
SELECT id_rayon, COUNT(id_ouvrage) AS nb_ouvrages
FROM ouvrages
GROUP BY id_rayon;





--Modifier l’adresse email d’un lecteur à partir de son identifiant.
UPDATE lecteurs
SET email = 'omari.email@example.com'
WHERE id_lecteur = 1;





--Mettre à jour le numéro de téléphone d’un lecteur à partir de son numéro CIN.
UPDATE lecteurs
SET telephone = '0612345678'
WHERE cin = 'AB123456';




--Modifier le rayon d’un ouvrage donné.
UPDATE ouvrages
SET id_rayon = 3
WHERE id_ouvrage = 1;




--Mettre à jour la date de retour effective d’un emprunt lors du retour d’un ouvrage.
UPDATE emprunts
SET date_retour_effective = CURDATE()
WHERE id_emprunt = 1;




--Modifier le chef d’un membre du personnel.
UPDATE personnel
SET id_chef = 2
WHERE id_personnel = 3;



--Supprimer un emprunt à partir de son identifiant.
DELETE FROM emprunts
WHERE id_emprunt = 5;




--Supprimer un lecteur n’ayant jamais effectué d’emprunt.
DELETE FROM lecteurs
WHERE NOT EXISTS (
    SELECT 1
    FROM emprunts
    WHERE emprunts.id_lecteur = lecteurs.id_lecteur
);



--Supprimer un ouvrage qui n’a jamais été emprunté.
DELETE ouvrages
WHERE NOT EXISTS (
    SELECT 1
    FROM emprunts
    WHERE emprunts.id_ouvrage = ouvrages.id_ouvrage
);



SHOW TABLES;
