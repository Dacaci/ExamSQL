-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : jeu. 20 mars 2025 à 15:52
-- Version du serveur : 9.1.0
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `bibliotheque`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `update_a_surveiller`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_a_surveiller` ()   BEGIN
    UPDATE adherents a
    JOIN emprunts e ON a.id_adherent = e.id_adherent
    SET a.a_surveiller = TRUE
    WHERE e.date_retour IS NULL 
    AND DATEDIFF(CURRENT_DATE, DATE_ADD(e.date_emprunt, INTERVAL 30 DAY)) > 30;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `adherents`
--

DROP TABLE IF EXISTS `adherents`;
CREATE TABLE IF NOT EXISTS `adherents` (
  `id_adherent` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `adresse` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_inscription` date NOT NULL,
  `a_surveiller` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id_adherent`),
  KEY `idx_adherents_nom` (`nom`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `adherents`
--

INSERT INTO `adherents` (`id_adherent`, `nom`, `adresse`, `date_inscription`, `a_surveiller`) VALUES
(1, 'Anonyme_1', 'Anonymisé', '2024-03-20', 0),
(2, 'Anonyme_2', 'Anonymisé', '2024-03-20', 0),
(3, 'Anonyme_3', 'Anonymisé', '2024-03-20', 0);

-- --------------------------------------------------------

--
-- Structure de la table `emprunts`
--

DROP TABLE IF EXISTS `emprunts`;
CREATE TABLE IF NOT EXISTS `emprunts` (
  `id_adherent` int NOT NULL,
  `isbn` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_emprunt` date NOT NULL,
  `date_retour` date DEFAULT NULL,
  PRIMARY KEY (`id_adherent`,`isbn`,`date_emprunt`),
  KEY `isbn` (`isbn`),
  KEY `idx_emprunts_date` (`date_emprunt`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `emprunts`
--

INSERT INTO `emprunts` (`id_adherent`, `isbn`, `date_emprunt`, `date_retour`) VALUES
(1, '978-1-234567-01-1', '2024-03-10', NULL),
(1, '978-1-234567-02-2', '2024-03-11', NULL),
(1, '978-1-234567-03-3', '2024-03-12', NULL),
(1, '978-1-234567-04-4', '2024-03-13', NULL),
(2, '978-1-234567-01-1', '2024-03-10', NULL),
(2, '978-1-234567-02-2', '2024-03-11', NULL),
(2, '978-1-234567-03-3', '2024-03-12', NULL),
(2, '978-1-234567-04-4', '2024-03-13', NULL),
(3, '978-1-234567-01-1', '2024-03-10', NULL),
(3, '978-1-234567-02-2', '2024-03-11', NULL),
(3, '978-1-234567-03-3', '2024-03-12', NULL),
(3, '978-1-234567-04-4', '2024-03-13', NULL),
(4, '978-1-234567-01-1', '2024-03-10', NULL),
(4, '978-1-234567-02-2', '2024-03-11', NULL),
(4, '978-1-234567-03-3', '2024-03-12', NULL),
(4, '978-1-234567-04-4', '2024-03-13', NULL);

--
-- Déclencheurs `emprunts`
--
DROP TRIGGER IF EXISTS `update_disponible_after_return`;
DELIMITER $$
CREATE TRIGGER `update_disponible_after_return` AFTER UPDATE ON `emprunts` FOR EACH ROW BEGIN
    IF NEW.date_retour IS NOT NULL AND OLD.date_retour IS NULL THEN
        UPDATE livres SET disponible = TRUE WHERE isbn = NEW.isbn;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `livres`
--

DROP TABLE IF EXISTS `livres`;
CREATE TABLE IF NOT EXISTS `livres` (
  `isbn` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `titre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `auteur` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `annee_publication` int DEFAULT NULL,
  `disponible` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`isbn`),
  KEY `idx_livres_disponible` (`disponible`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `livres`
--

INSERT INTO `livres` (`isbn`, `titre`, `auteur`, `annee_publication`, `disponible`) VALUES
('978-1-234567-01-1', 'Orgueil et Préjugés', 'Jane Austen', 1813, 1),
('978-1-234567-02-2', 'David Copperfield', 'Charles Dickens', 1850, 1),
('978-1-234567-03-3', 'Vingt mille lieues sous les mers', 'Jules Verne', 1870, 1),
('978-1-234567-04-4', 'Frankenstein', 'Mary Shelley', 1818, 1);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `vue_livres_en_retard`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `vue_livres_en_retard`;
CREATE TABLE IF NOT EXISTS `vue_livres_en_retard` (
`id_adherent` int
,`nom_adherent` varchar(100)
,`adresse` text
,`isbn` varchar(20)
,`titre` varchar(255)
,`auteur` varchar(255)
,`date_emprunt` date
);

-- --------------------------------------------------------

--
-- Structure de la vue `vue_livres_en_retard`
--
DROP TABLE IF EXISTS `vue_livres_en_retard`;

DROP VIEW IF EXISTS `vue_livres_en_retard`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vue_livres_en_retard`  AS SELECT `a`.`id_adherent` AS `id_adherent`, `a`.`nom` AS `nom_adherent`, `a`.`adresse` AS `adresse`, `l`.`isbn` AS `isbn`, `l`.`titre` AS `titre`, `l`.`auteur` AS `auteur`, `e`.`date_emprunt` AS `date_emprunt` FROM ((`adherents` `a` join `emprunts` `e` on((`a`.`id_adherent` = `e`.`id_adherent`))) join `livres` `l` on((`e`.`isbn` = `l`.`isbn`))) WHERE ((`e`.`date_retour` is null) AND ((`e`.`date_emprunt` + interval 30 day) < curdate())) ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
