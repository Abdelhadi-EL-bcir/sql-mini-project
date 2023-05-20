--La conception : 
--3
---a
CREATE TABLE PRODUIT 
(
    ref_produit number(8) PRIMARY KEY,
    nom_produit  VARCHAR(48) NOT NULL,
    designation VARCHAR(30) NOT NULL , 
    prix_vente   number(6,2) NOT NULL, 
    quantite_stocke number default 0 
) ;

CREATE TABLE Client (
    id_client NUMBER(10) PRIMARY KEY,
    nom_client VARCHAR2(50) NOT NULL,
    prenom_client VARCHAR2(50) NOT NULL,
	  date_naiss_client DATE NOT NULL,
    tel_client VARCHAR2(20) NOT NULL,
   	adresse_client VARCHAR2(20) NOT NULL,
	  mail_client VARCHAR2(30) NOT NULL
);

CREATE TABLE Facture (
    id_facture NUMBER(10) PRIMARY KEY,
    date_facture DATE NOT NULL,
    client_id NUMBER(10) NOT NULL,
    CONSTRAINT fk_facture_client_id
        FOREIGN KEY (client_id) REFERENCES Client(id_client)
);

CREATE TABLE Facture_Produit (
  facture_id number NOT NULL,
  produit_id number(8) NOT NULL,
  quantite_vendu number default 0,
   constraint pk_fp PRIMARY KEY (facture_id, produit_id),
   constraint fk_f FOREIGN KEY (facture_id) REFERENCES Facture(id_facture),
   constraint fk_p FOREIGN KEY (produit_id) REFERENCES Produit(ref_produit)
);

create sequence client_seq
start with 10000
increment by 1 ; 

create sequence produit_seq
start with 10000
increment by 1 ;

create sequence facture_seq
start with 10000
increment by 1 ; 

---b

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (1, 'Product 1', 'Designation 1', 10.99, 100);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (2, 'Product 2', 'Designation 2', 19.99, 50);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (3, 'Product 3', 'Designation 3', 5.99, 200);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (4, 'Product 4', 'Designation 4', 14.99, 75);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (5, 'Product 5', 'Designation 5', 9.99, 150);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (6, 'Product 6', 'Designation 6', 7.99, 300);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (7, 'Product 7', 'Designation 7', 11.99, 90);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (8, 'Product 8', 'Designation 8', 6.99, 250);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (9, 'Product 9', 'Designation 9', 8.99, 120);

INSERT INTO PRODUIT (ref_produit, nom_produit, designation, prix_vente, quantite_stocke)
VALUES (10, 'Product 10', 'Designation 10', 12.99, 180);

INSERT INTO Client VALUES (1, 'Doe', 'John', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '1234567890', '123 Main St', 'johndoe@email.com');
INSERT INTO Client VALUES (2, 'Smith', 'Jane', TO_DATE('1985-05-12', 'YYYY-MM-DD'), '0987654321', '456 Maple Ave', 'janesmith@email.com');

INSERT INTO Facture VALUES (1, TO_DATE('2023-05-13', 'YYYY-MM-DD'), 1);
INSERT INTO Facture VALUES (3, TO_DATE('2023-05-13', 'YYYY-MM-DD'), 1);
INSERT INTO Facture VALUES (4, TO_DATE('2023-05-13', 'YYYY-MM-DD'), 1);
INSERT INTO Facture VALUES (2, TO_DATE('2023-05-12', 'YYYY-MM-DD'), 2);

INSERT INTO Facture_Produit VALUES (1, 1, 2);
INSERT INTO Facture_Produit VALUES (1, 2, 1);
INSERT INTO Facture_Produit VALUES (2, 3, 3);


INSERT INTO Facture_Produit VALUES (1, 3, 1010);
--4 Écrivez et exécutez la requête permettant d'afficher toutes les lignes de facture, avec pour chacune : 
SELECT
  f.id_facture,
  (SELECT nom_client FROM Client c WHERE c.id_client = f.client_id) AS nom_client,
  (SELECT prenom_client FROM Client c WHERE c.id_client = f.client_id) AS prenom_client,
  (SELECT nom_produit FROM Produit p WHERE p.ref_produit = fp.produit_id) AS nom_produit,
  (SELECT prix_vente FROM Produit p WHERE p.ref_produit = fp.produit_id) AS prix_produit,
  fp.quantite_vendu
FROM Facture_Produit fp, Facture f
WHERE f.id_facture = fp.facture_id;
--Les vues: 
CREATE VIEW v_chiffre_affaire AS
 SELECT
    f.CLIENT_ID, SUM(FP.quantite_vendu * P.prix_vente) as CA,
    CASE
        WHEN SUM(FP.quantite_vendu * P.prix_vente)> 500 THEN 'VIP'
        WHEN SUM(FP.quantite_vendu * P.prix_vente) BETWEEN 50 AND 500 THEN 'client ordinaire'
        ELSE 'client à potentiel'
    END AS categorie
 FROM Facture_Produit FP, Produit P ,  facture f
            WHERE FP.facture_id = F.id_facture
            AND FP.produit_id = P.ref_produit
            Group by f.CLIENT_ID;

-- Fonctions stockées : 

--1 
CREATE OR REPLACE FUNCTION demande_produit(num_produit IN NUMBER)
RETURN VARCHAR2
AS
  v_demande VARCHAR2(10);
  v_quantite_vendue NUMBER;
BEGIN
  SELECT SUM(quantite_vendu)
  INTO v_quantite_vendue
  FROM Facture_Produit
  WHERE produit_id = num_produit;
  
  IF v_quantite_vendue > 15 THEN
    v_demande := 'Forte';
  ELSIF v_quantite_vendue >= 11 AND v_quantite_vendue <= 15 THEN
    v_demande := 'Moyenne';
  ELSE
    v_demande := 'Faible';
  END IF;
  
  RETURN v_demande;
END;
/
--2
SELECT 
  p.nom_produit AS nom , 
  p.designation AS produit, 
  p.prix_vente AS prix, 
  demande_produit(p.ref_produit) 
FROM 
  Produit p ;
--Les curseurs : 
--1
CREATE OR REPLACE FUNCTION nb_factures_client(p_client_id NUMBER) RETURN NUMBER AS
  nb_factures NUMBER;
BEGIN
  SELECT COUNT(*) INTO nb_factures
  FROM Facture
  WHERE client_id = p_client_id;
  RETURN nb_factures;
END;
/
 
CREATE OR REPLACE FUNCTION ca_client(client_id NUMBER) 
  RETURN NUMBER AS
  v_ca NUMBER;
BEGIN
  SELECT SUM(fp.quantite_vendu * p.prix_vente) INTO v_ca
  FROM Facture_Produit fp , Produit p , Facture f
  WHERE f.client_id = client_id 
  and fp.produit_id = p.ref_produit
  and fp.facture_id = f.id_facture;
  
  RETURN v_ca;
END;
/

--2
DECLARE
  client_id NUMBER := 1;
  nb_factures NUMBER;
  ca NUMBER;
BEGIN
  nb_factures := nb_factures_client(client_id);
  ca := ca_client(client_id);
  DBMS_OUTPUT.PUT_LINE('Client ' || client_id || ' : ' || nb_factures || ' factures, chiffre d''affaires de ' || ca || ' euros');
END;
/
--3
DECLARE
  cursor c_clients IS
    SELECT id_client, nom_client, prenom_client
    FROM Client;
  client_id NUMBER;
  nb_factures NUMBER;
  ca NUMBER;
BEGIN
  FOR c IN c_clients LOOP
    nb_factures := nb_factures_client(c.id_client);
    ca := ca_client(c.id_client);
    DBMS_OUTPUT.PUT_LINE(c.nom_client || ' ' || c.prenom_client || ' : ' || nb_factures || ' factures, chiffre d''affaires de ' || ca || ' euros');
  END LOOP;
END;
/
--4
CREATE OR REPLACE PROCEDURE profil_client(client_id NUMBER) AS
  nb_factures NUMBER;
  ca NUMBER;
BEGIN
  nb_factures := nb_factures_client(client_id);
  ca := ca_client(client_id);
  DBMS_OUTPUT.PUT_LINE('Client ' || client_id || ' : ' || nb_factures || ' factures, chiffre d''affaires de ' || ca || ' euros');
END;
/

BEGIN
  profil_client(1);
END;
/ 

--Triggers 
---1 
-- CREATE OR REPLACE TRIGGER manage_quantite
-- AFTER INSERT ON Facture_Produit
-- FOR EACH ROW
-- DECLARE
--   v_quantite_vendu Facture_Produit.quantite_vendu%type;
--   v_quantite_restant NUMBER(6,2);
--   v_quantite_stocke PRODUIT.quantite_stocke%type ; 
-- BEGIN
--   SELECT quantite_vendu INTO v_quantite_vendu
--   FROM Facture_Produit
--    WHERE facture_id = :new.facture_id ;
  
--   SELECT quantite_stocke
--   INTO v_quantite_stocke
--   FROM PRODUIT
--   WHERE ref_produit = :new.produit_id

--   v_quantite_restant := v_quantite_stocke - v_quantite_vendu;

--   UPDATE PRODUIT
--   SET quantite_stocke = v_quantite_restant
--   WHERE ref_produit = :new.produit_id;

-- END;
-- /

CREATE TABLE Stock_Audit (
  id_audit NUMBER(10) PRIMARY KEY,
  date_audit DATE NOT NULL,
  ref_produit NUMBER(8) NOT NULL,
  stock_restant NUMBER(6,2) NOT NULL
);

create sequence audit_seq
start with 1
increment by 1 ; 

create or replace TRIGGER manage_quantite
AFTER INSERT ON Facture_Produit
FOR EACH ROW
DECLARE
 v_quantite_stocke Produit.QUANTITE_STOCKE%type ; 
begin

  select QUANTITE_STOCKE
    into v_quantite_stocke
    from Produit
   where ref_produit = :new.produit_id ; 

   if :new.quantite_vendu > v_quantite_stocke then
     raise_application_error(-20001, 'Quantité insufisant');
   end if;

  v_quantite_stocke := v_quantite_stocke - :new.quantite_vendu;

  UPDATE PRODUIT
  SET quantite_stocke = v_quantite_stocke
  WHERE ref_produit = :new.produit_id;
  
  IF v_quantite_stocke < 5 THEN
    INSERT INTO Stock_Audit 
    VALUES (audit_seq.nextval, SYSDATE, :new.produit_id, v_quantite_stocke );
  END IF;

end;
