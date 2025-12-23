enum ChallengeCategory { suave, picante, extremo }

class Challenge {
  final String text;
  final ChallengeCategory category;

  const Challenge(this.text, this.category);
}

const List<Challenge> challenges = [
  Challenge("Bebe 1 trago.", ChallengeCategory.suave),
  Challenge("El de tu derecha bebe 1 trago.", ChallengeCategory.suave),
  Challenge("Todos beben 1.", ChallengeCategory.suave),
  Challenge("Imita a alguien del grupo 5 segundos o bebe.", ChallengeCategory.suave),
  Challenge("Cuenta una anécdota vergonzosa o bebe.", ChallengeCategory.suave),
  Challenge("Manda un emoji sospechoso a tu último chat o bebe.", ChallengeCategory.picante),
  Challenge("Di quién te parece más atractivo/a del grupo o bebe.", ChallengeCategory.picante),
  Challenge("Besa a alguien en la mejilla o bebe 2.", ChallengeCategory.picante),
  Challenge("Confiesa tu mayor red flag o bebe.", ChallengeCategory.picante),
  Challenge("Enseña tu última foto de galería o bebe 2.", ChallengeCategory.picante),
  Challenge("Llama a alguien y di 'te echo de menos' o bebe 3.", ChallengeCategory.extremo),
  Challenge("Deja que te escriban una frase en el brazo o bebe 2.", ChallengeCategory.extremo),
  Challenge("Haz 10 flexiones o bebe 3.", ChallengeCategory.extremo),
  Challenge("Deja que el grupo revise tu Instagram 30s o bebe 3.", ChallengeCategory.extremo),
  Challenge("Cuenta tu secreto más fuerte o bebe 4.", ChallengeCategory.extremo),
];
