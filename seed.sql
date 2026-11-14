-- Official research portals are NOT the text of laws. They are directory entries until human-reviewed.
INSERT OR IGNORE INTO sources(title,url,publisher,jurisdiction,instrument_type,status,notes) VALUES
('Pakistan Code — Federal Laws','https://pakistancode.gov.pk/','Ministry of Law and Justice, Pakistan','PK-FED','official portal','verified','Verified as an official legal research portal; individual laws must be reviewed separately.'),
('National Assembly of Pakistan','https://www.na.gov.pk/','National Assembly of Pakistan','PK-FED','official portal','verified','Parliamentary source; verify instruments individually.'),
('Punjab Laws','https://punjablaws.gov.pk/','Government of Punjab','PK-PB','official portal','verified','Provincial legislation portal; verify instruments individually.'),
('Sindh Laws','https://www.sindhlaws.gov.pk/','Government of Sindh','PK-SD','official portal','verified','Provincial legislation portal; verify instruments individually.'),
('United Nations Treaty Collection','https://treaties.un.org/','United Nations','INT','official portal','verified','Check treaty status, reservations and domestic applicability.'),
('OHCHR Treaty Bodies','https://www.ohchr.org/en/treaty-bodies','United Nations OHCHR','INT','official portal','verified','Human rights treaty information; not automatically domestic law.');
-- Intentionally no verified legal_entries are seeded: no law is treated as reviewed without review.
