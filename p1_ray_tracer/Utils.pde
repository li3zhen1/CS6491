
final class Pair<T1, T2> {
    T1 first;
    T2 second;

    Pair(T1 item1, T2 item2) {
        this.first = item1;
        this.second = item2;
    }
}

final class Triple<T1, T2, T3> {
    T1 first;
    T2 second;
    T3 third;

    Triple(T1 item1, T2 item2, T3 item3) {
        this.first = item1;
        this.second = item2;
        this.third = item3;
    }
}

final class Optional<T> {
    T value;

    Optional(T value) {
        this.value = value;
    }

    Optional() {
        this.value = null;
    }

    boolean isEmpty() {
        return value == null;
    }

    T value() {
        return value;
    }
}