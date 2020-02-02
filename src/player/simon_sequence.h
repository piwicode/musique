class SimonSequence {
    byte table[255];
    int len;

  public:
    SimonSequence(): table {
      0
    }, len(0) {}

    void add(byte value) {
      if (len < 255) {
        table[len++] = value;
      }
    }

    byte get(int index) {
      return index < len ? table[index] : 0;
    }

    int size() {
      return len;
    }
};
