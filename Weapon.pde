class Weapon {
    int type; // 0 - saw blade, 1 - laser, 2 - hammer
    Robot robot;

    Weapon(int type, Robot robot) {
        this.type = type;
        this.robot = robot;
    }
}

class SawBlade extends Weapon {
    SawBlade(Robot robot) {
        super(0, robot);
    }
}