



class PikachuGenerator {


    ImplicitInterface _ear_base = taperOnX(
            (x, y, z) -> a_sphere.getValue(0.66*x, 2*y, 4*z),
            -2.0,
            2.0,
            1.2,
            0.6
        );

    ImplicitInterface _eye_base = (x, y, z) -> {
        return a_sphere.getValue(3*x, 3*y, 7*z);
    };

    PVector eye_color = new PVector(0.0, 0.0, 0.0);
    PVector eye_white_color = new PVector(255.0, 255.0, 255.0);
    PVector skin_color = new PVector(230.0, 220.0, 90.0);
    PVector cheek_color = new PVector(220.0, 70.0, 40.0);

    ColoredImplicitInterface generateColor() {
        if (!prepared) {
            prepare();
        }
        ColoredImplicitInterface pikachu = (x, y, z) -> {

            y = y*1.08;
            float d2 = x*x + y*y + z*z;


            

            float head = blobby(a_sphere.getValue(1.05*x, y, 1.2*z) - 0.45) +
                blobby(a_sphere.getValue(1.08*x, (y*2)-0.8, 1.25*z) - 0.26);

            float body = blobby(1.2*_body.getValue(x, y, z) - 0.3) +
                blobby(a_sphere.getValue(0.7*x, 0.7*(y-1.72), 0.7*z) - 0.28);

            float ear = blobby(_ear_r.getValue(x, y, z) - 0.8)
                + blobby(_ear_l.getValue(x, y, z) - 0.8);

            float eye = blobby(_eye_r.getValue(x, y, z) - 0.4)
                + blobby(_eye_l.getValue(x, y, z) - 0.4);

            float eye_white = blobby(_eye_white_r.getValue(x, y, z) - 0.4)
                + blobby(_eye_white_l.getValue(x, y, z) - 0.4);

            float cheek = blobby(_cheek_r.getValue(x, y, z) - 0.5) +
                blobby(_cheek_l.getValue(x, y, z) - 0.5);

            float nose = blobby(_nose.getValue(x, y, z) - 0.7);

            float arm = blobby(_arm_l.getValue(x, y, z) - 0.05) +
                blobby(_arm_r.getValue(x, y, z) - 0.05);

            float mouth = blobby(
                _mouth.getValue(x, y, z) - 0.2
            );

            float tail = blobby(
                _tail.getValue(x, y, z) - 0.2
            );

            float all_ratio = head + ear + eye + nose + mouth + cheek + eye_white + body + arm + tail;
            float eye_ratio = 30*(eye+nose+mouth) / all_ratio;
            float cheek_ratio = 4*cheek / all_ratio;
            float eye_white_ratio = 60*eye_white / all_ratio;


            
            // return skin_color;
            var base_color = new PVector(
                eye_color.x * eye_ratio + skin_color.x * (1 - eye_ratio - cheek_ratio) + cheek_color.x * cheek_ratio + eye_white_color.x * eye_white_ratio,
                eye_color.y * eye_ratio + skin_color.y * (1 - eye_ratio - cheek_ratio) + cheek_color.y * cheek_ratio + eye_white_color.y * eye_white_ratio,
                eye_color.z * eye_ratio + skin_color.z * (1 - eye_ratio - cheek_ratio) + cheek_color.z * cheek_ratio + eye_white_color.z * eye_white_ratio
            );
            if (y > 0) {
                return base_color;
            }

            float ratio = (d2 - 1.8) / (2.4 - 1.8);
            ratio = max(0, min(1, ratio));
            return new PVector(
                base_color.x * (1 - ratio),
                base_color.y * (1 - ratio),
                base_color.z * (1 - ratio)
            );
        };
        return pikachu;
    };

PMatrix3D eye_right_transform;
PMatrix3D eye_left_transform;

PMatrix3D eye_white_right_transform;
PMatrix3D eye_white_left_transform;

PMatrix3D ear_right_transform;
PMatrix3D ear_left_transform;
PMatrix3D cheek_right_transform;
PMatrix3D cheek_left_transform;
PMatrix3D nose_transform;
PMatrix3D mouth_transform;
PMatrix3D body_transform;

PMatrix3D arm_l_transform;
PMatrix3D arm_r_transform;
PMatrix3D tail_transform;

    void prepare() {
        float ear_scale_ratio = 3f;


        ear_right_transform = new PMatrix3D();
        ear_right_transform.scale(ear_scale_ratio, ear_scale_ratio, ear_scale_ratio);
        ear_right_transform.rotateZ(PI*0.15);
        ear_right_transform.translate(-1.16, 0.86, 0.1);

        ear_left_transform = new PMatrix3D();
        ear_left_transform.scale(ear_scale_ratio, ear_scale_ratio, ear_scale_ratio);
        ear_left_transform.rotateZ(PI*0.56);
        ear_left_transform.translate(0.73, 1.22, 0.1);

        eye_right_transform = new PMatrix3D();
        eye_right_transform.rotateY(PI/10);
        eye_right_transform.rotateX(-PI/10);
        eye_right_transform.rotateZ(PI/10);
        eye_right_transform.scale(4, 4.2, 3.2);
        eye_right_transform.translate(0.3, 0.1, -0.54);

        eye_white_right_transform = new PMatrix3D();
        eye_white_right_transform.rotateY(PI/10);
        eye_white_right_transform.rotateX(-PI/10);
        eye_white_right_transform.rotateZ(PI/10);
        eye_white_right_transform.scale(7, 7.2, 3.2);
        eye_white_right_transform.translate(0.3, 0.12, -0.54);

        eye_left_transform = new PMatrix3D();
        eye_left_transform.rotateY(-PI/10);
        eye_left_transform.rotateX(-PI/10);
        eye_left_transform.rotateZ(-PI/10);
        eye_left_transform.scale(4, 4.2, 3.2);
        eye_left_transform.translate(-0.3, 0.1, -0.54);

        eye_white_left_transform = new PMatrix3D();
        eye_white_left_transform.rotateY(-PI/10);
        eye_white_left_transform.rotateX(-PI/10);
        eye_white_left_transform.rotateZ(-PI/10);
        eye_white_left_transform.scale(7, 7.2, 3.2);
        eye_white_left_transform.translate(-0.3, 0.12, -0.54);


        cheek_right_transform = new PMatrix3D();
        cheek_right_transform.rotateY(PI/4);
        cheek_right_transform.rotateX(-PI/10);
        cheek_right_transform.rotateZ(PI/8);
        cheek_right_transform.scale(1.9, 2.0, 2.8);
        cheek_right_transform.translate(0.52, -0.3, -0.5);

        cheek_left_transform = new PMatrix3D();
        cheek_left_transform.rotateY(-PI/4);
        cheek_left_transform.rotateX(-PI/10);
        cheek_left_transform.rotateZ(-PI/8);
        cheek_left_transform.scale(1.9, 2.0, 2.8);
        cheek_left_transform.translate(-0.52, -0.3, -0.5);

        nose_transform = new PMatrix3D();
        nose_transform.scale(8, 8, 6);
        // nose_transform.rotateX(PI/10);
        nose_transform.rotateZ(PI/2);
        nose_transform.translate(0, -0.15, -0.67);

        mouth_transform = new PMatrix3D();
        mouth_transform.scale(16, -30, 20);
        mouth_transform.translate(0, -0.32, -0.71);

        body_transform = new PMatrix3D();
        body_transform.rotateZ(-PI/2);
        body_transform.translate(0.0, -1.0, 0.0);
        body_transform.scale(1.0, 0.7, 1.0);


        arm_l_transform = new PMatrix3D();
        arm_l_transform.rotateZ(PI*1.3);
        arm_l_transform.rotateX(PI*0.45);
        arm_l_transform.translate(-1.9, -2.9, -1);
        float arm_scale = 3.0;
        arm_l_transform.scale(arm_scale, arm_scale, arm_scale);

        arm_r_transform = arm_l_transform.get();
        arm_r_transform.scale(-1, 1, 1);






        _ear_r = transform(
            twistOnX(_ear_base, -0.3),
            ear_right_transform
        );

        _ear_l = transform(
            twistOnX(_ear_base, 0.3),
            ear_left_transform
        );



        _eye_white_r = transform(
            _eye_base,
            eye_white_right_transform
        );

        _eye_white_l = transform(
            _eye_base,
            eye_white_left_transform
        );

        _eye_r = transform(
            substractionOf(
                _eye_base,
                _eye_white_r
            ),
            eye_right_transform
        );

        _eye_l = transform(
            _eye_base,
            eye_left_transform
        );

        _cheek_r = transform(
            _eye_base,
            cheek_right_transform
        );

        _cheek_l = transform(
            _eye_base,
            cheek_left_transform
        );

        _nose = transform(
            taperOnX(
                _eye_base,
                -1.0,
                1.0,
                0.5,
                2
            ),
            nose_transform
        );


        float offset = 0.5;
        var line = new LineSegmentGenerator(
                    new PVector(-1.5, offset, 0),
                    new PVector(1.5, offset, 0)
                );
        _mouth = transform(
            twistOnX(line.generate(), 3),
            mouth_transform
        );

        _body = transform(
            taperOnX(
                a_sphere,
                -1.0,
                1.0,
                0.5,
                1.5
            ),
            body_transform
        );


        var __arm = new LineSegmentGenerator(
            new PVector(-1.0, -0.1, 0),
            new PVector(1.0, -0.1, 0)
        ).generate();

        var arm_base = taperOnX(
                twistOnX(__arm, 2),
                -1.0,
                1.0,
                1.0,
                0.9
            );
        _arm_l = transform(
            arm_base, 
            arm_l_transform
        );

        _arm_r = transform(
            arm_base, 
            arm_r_transform
        );


        PMatrix3D m = new PMatrix3D();
        m.translate(0, -0.3, 0);
        var tl = new LineSegmentGenerator(
            new PVector(-1.5, 0, 0),
            new PVector(1.5, 0, 0)
        );
        tail_transform = new PMatrix3D();
        tail_transform.scale(2, 2, 2);
        tail_transform.rotateZ(PI/6);
        tail_transform.rotateY(-PI/3);
        tail_transform.translate(-1.0, -1.5, 0.6);

        _tail = transform(
            taperOnX(
                twistOnX(
                    transform(
                        tl.generate(),
                        m
                    ),
                    8
                ),
            -1.5,
            1.7,
            0.3,
            1.2
            ),
            tail_transform
        );

        

        prepared = true;
    }

    ImplicitInterface _ear_r;
    ImplicitInterface _ear_l;
    ImplicitInterface _eye_r;
    ImplicitInterface _eye_l;
    ImplicitInterface _cheek_r;
    ImplicitInterface _cheek_l;
    ImplicitInterface _nose;
    ImplicitInterface _mouth;
    ImplicitInterface _eye_white_r;
    ImplicitInterface _eye_white_l;
    ImplicitInterface _body;
    ImplicitInterface _thigh_l;
    ImplicitInterface _thigh_r;
    ImplicitInterface _arm_l;
    ImplicitInterface _arm_r;
    ImplicitInterface _tail;
    
    boolean prepared = false;
    ImplicitInterface generate() {
        if (!prepared) {
            prepare();
        }
        
        ImplicitInterface pikachu = (x, y, z) -> {
            y = y*1.08;
            

            float head = blobby(a_sphere.getValue(1.05*x, y, 1.2*z) - 0.45) +
                blobby(a_sphere.getValue(1.08*x, (y*2)-0.8, 1.25*z) - 0.26);

            float body = blobby(1.2*_body.getValue(x, y, z) - 0.3) +
                blobby(a_sphere.getValue(0.7*x, 0.7*(y-1.72), 0.7*z) - 0.28);

            float ear = blobby(_ear_r.getValue(x, y, z) - 0.8)
                + blobby(_ear_l.getValue(x, y, z) - 0.8);

            float eye = blobby(_eye_r.getValue(x, y, z) - 0.4)
                + blobby(_eye_l.getValue(x, y, z) - 0.4);

            float eye_white = blobby(_eye_white_r.getValue(x, y, z) - 0.4)
                + blobby(_eye_white_l.getValue(x, y, z) - 0.4);

            float cheek = blobby(_cheek_r.getValue(x, y, z) - 0.5) +
                blobby(_cheek_l.getValue(x, y, z) - 0.5);

            float nose = blobby(_nose.getValue(x, y, z) - 0.7);

            float arm = blobby(_arm_l.getValue(x, y, z) - 0.05) +
                blobby(_arm_r.getValue(x, y, z) - 0.05);

            float mouth = blobby(
                _mouth.getValue(x, y, z) - 0.2
            );

            float tail = blobby(
                _tail.getValue(x, y, z) - 0.2
            );

            // return tail;
            return tail+head + ear + eye + cheek + nose + eye_white + mouth + body + arm;
        };

        return pikachu;
    };
}