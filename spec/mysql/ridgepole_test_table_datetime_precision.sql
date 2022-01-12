USE `ridgepole_test`;

DROP TABLE IF EXISTS `clubs`;
CREATE TABLE `datetimes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `datetime_zero` datetime(0) NOT NULL,
  `datetime_six` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);
