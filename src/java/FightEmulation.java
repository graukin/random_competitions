import java.util.Random;

public class FightEmulation {
    private static Random rand;
    
    private static class Warrior {
        private int power;
        private int HP;
        private int armor;
        private String name;
        
        public Warrior(String name) {
            power = 20;
            HP = 40;
            armor = 40;
            this.name = name;
        }
        
        public int hit() {
            int die = rand.nextInt(20)+1;
            System.out.print("  power = " + power + ", d20 = " + die + ", damage: ");
            if (die == 1) {
                System.out.println("0 (automiss)");
                return 0;
            }
            if (die == 20) {
                System.out.println(power*2 + " (critical)");
                return power*2;
            }
            else {
                int damage = (int) (power*(die*0.05));
                System.out.println(damage);
                return damage;
            }
        }
        
        public boolean isHitted(int damage) {
            int die = rand.nextInt(20)+1;
            if (die > damage + 5) {
                System.out.println("  dodge!");
                damage = Math.min(2, damage);
            }
            armor -= damage/2;
            System.out.print("  armor -" + damage/2);
            if (armor < 0) {
                HP += armor;
                HP -= damage/2;
                System.out.print(", HP -" + (-armor + damage/2) + "\n");
                armor = 0;
            } else {
                HP -= damage/4;
                System.out.print(", HP -" + (damage/4) + "\n");
            }
            
            if (HP <= 0) return false;
            else if (HP < 10) power = 5;
            else if (HP < 20) power = 10;
            else if (HP < 30) power = 15;
            
            return true;
        }
        
        public void printStats() {
            System.out.println("  " + name + "\n" +
                               "   HP = " + HP + "\n" +
                               "   Armor = " + armor);
        }
        
        public String name() {
            return name;
        }
    }
    
    private static Warrior w1;
    private static Warrior w2;
    
    private static void init() {
        rand = new Random(System.currentTimeMillis());
        
        w1 = new Warrior("Zebo");
        w2 = new Warrior("Mugi4ok");
    }
    
    public static void main(String args[]) throws Exception {
        init();
        
        int roundNum = 1;
        while (true) {
            System.out.println("----------------\n" + 
                               "Round #" + roundNum++);
            w1.printStats();
            w2.printStats();
            
            System.out.println(w1.name() + " hit:");
            int hit = w1.hit();
            if (! w2.isHitted(hit)) {
                System.out.println("\n" + w1.name() + " win battle");
                return;
            }
            System.out.println(w2.name() + " hit:");
            hit = w2.hit();
            if (! w1.isHitted(hit)) {
                System.out.println("\n" + w2.name() + " win battle");
                return;
            }
            
            Thread.sleep(10);
        }
    }
}
