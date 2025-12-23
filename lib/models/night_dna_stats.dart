class NightDnaStats {
  int drinksTaken;
  int wins;
  int losses;
  int punishmentsGiven;

  NightDnaStats({
    this.drinksTaken = 0,
    this.wins = 0,
    this.losses = 0,
    this.punishmentsGiven = 0,
  });

  int get dominanceScore => punishmentsGiven - drinksTaken;
}
