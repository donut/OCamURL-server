CREATE TABLE `url` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scheme` enum('HTTP','HTTPS') NOT NULL,
  `user` varchar(1000) DEFAULT NULL,
  `password` varchar(1000) DEFAULT NULL,
  `host` varchar(255) NOT NULL DEFAULT '',
  `port` int(11) unsigned DEFAULT NULL,
  `path` varchar(6000) NOT NULL DEFAULT '',
  `params` varchar(6000) DEFAULT NULL,
  `fragment` varchar(6000) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `modified_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `alias` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `url` int(11) unsigned NOT NULL,
  `status` enum('ENABLED','DISABLED') NOT NULL DEFAULT 'ENABLED',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `modified_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `alias_url-url_id` (`url`),
  CONSTRAINT `alias_url-url_id` FOREIGN KEY (`url`) REFERENCES `url` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `use` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `alias` int(11) unsigned NOT NULL,
  `url` int(11) unsigned NOT NULL,
  `referrer` int(11) unsigned DEFAULT NULL,
  `user_agent` varchar(3000) DEFAULT NULL,
  `ip` varchar(255) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `modified_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `use_alias-alias_id` (`alias`),
  KEY `use_url-url_id` (`url`),
  KEY `use_referrer-url_id` (`referrer`),
  CONSTRAINT `use_alias-alias_id` FOREIGN KEY (`alias`) REFERENCES `alias` (`id`),
  CONSTRAINT `use_referrer-url_id` FOREIGN KEY (`referrer`) REFERENCES `url` (`id`),
  CONSTRAINT `use_url-url_id` FOREIGN KEY (`url`) REFERENCES `url` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
