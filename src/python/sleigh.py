from random import randrange


class Sleigh:
    MAX_SPEED = 3.6  # m/s

    _distance = 0
    _acceleration = 0
    _speed = 0
    _rider = None

    def __init__(self, rider):
        self._rider = rider

    @classmethod
    def _count_accel_shift(cls):
        thr = randrange(1, 20)  # [1, 19] - 10 in the middle
        shift = (thr - 6) * 0.05
        return shift

    def start_boost(self):
        self._acceleration = 0.1  # m/s^2

    def time_point(self, time):
        self._distance = self._distance + self._speed*time + (max(self._acceleration*time*time/2, 0.0) if self._speed < self.MAX_SPEED else 0)
        if randrange(1, 101) <= 5:
            self._acceleration = 0
            self._speed = self._speed / 2
        self._speed = max(0.0, min(self.MAX_SPEED, self._speed + self._acceleration*time))

    def update_acceleration(self):
        self._acceleration = self._acceleration + Sleigh._count_accel_shift()
        if self._speed == 0:
            self._acceleration = max(0.0, self._acceleration)

    def print_text_data(self):
        print(self._rider + " : " + str(self._distance) + " // " + str(self._speed) + " " + str(self._acceleration))
