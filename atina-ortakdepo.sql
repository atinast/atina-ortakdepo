CREATE TABLE IF NOT EXISTS `atina_storages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner` VARCHAR(50) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `code` INT NOT NULL UNIQUE,
    `password` VARCHAR(4) NOT NULL,
    `members` LONGTEXT DEFAULT '[]'
);