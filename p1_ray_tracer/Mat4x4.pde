
final class Mat4x4 {

    final PMatrix3D toPMatrix3D() {
        PMatrix3D mat = new PMatrix3D(
            this.mat[0][0], this.mat[0][1], this.mat[0][2], this.mat[0][3],
            this.mat[1][0], this.mat[1][1], this.mat[1][2], this.mat[1][3],
            this.mat[2][0], this.mat[2][1], this.mat[2][2], this.mat[2][3],
            this.mat[3][0], this.mat[3][1], this.mat[3][2], this.mat[3][3]
        );
        return mat;
    }
    


    final float[][] mat;


    

    public void dump() {
        System.out.println("Mat4x4(");
        for (int i = 0; i < 4; i++) {
            System.out.println("    " + this.mat[i][0] + ", " + this.mat[i][1] + ", " + this.mat[i][2] + ", " + this.mat[i][3]);
        }
        System.out.println(")");
    }

    public Mat4x4(
        float[][] mat
    ) {
        this.mat = mat;
    }


    public PVector applyTo(PVector vec) {
        float x = vec.x;
        float y = vec.y;
        float z = vec.z;
        float w = 1.0f;

        float newX = x * this.mat[0][0] + y * this.mat[0][1] + z * this.mat[0][2] + w * this.mat[0][3];
        float newY = x * this.mat[1][0] + y * this.mat[1][1] + z * this.mat[1][2] + w * this.mat[1][3];
        float newZ = x * this.mat[2][0] + y * this.mat[2][1] + z * this.mat[2][2] + w * this.mat[2][3];

        return new PVector(newX, newY, newZ);
    }


    final Mat4x4 copy() {
        float[][] newMat = new float[4][4];

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                newMat[i][j] = this.mat[i][j];
            }
        }

        return new Mat4x4(newMat);
    }


    final Mat4x4 dot(Mat4x4 other) {

        float[][] newMat = new float[4][4];

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                float sum = 0;
                for (int k = 0; k < 4; k++) {
                    sum += this.mat[i][k] * other.mat[k][j];
                }
                newMat[i][j] = sum;
            }
        }

        return new Mat4x4(newMat);
    }

    final Mat4x4 add(Mat4x4 other) {
        float[][] newMat = new float[4][4];

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                newMat[i][j] = this.mat[i][j] + other.mat[i][j];
            }
        }

        return new Mat4x4(newMat);
    }


    final Mat4x4 sub(Mat4x4 other) {
        float[][] newMat = new float[4][4];

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                newMat[i][j] = this.mat[i][j] - other.mat[i][j];
            }
        }

        return new Mat4x4(newMat);
    }


    final Mat4x4 elementwiseMultiply(Mat4x4 other) {
        float[][] newMat = new float[4][4];

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                newMat[i][j] = this.mat[i][j] * other.mat[i][j];
            }
        }

        return new Mat4x4(newMat);
    }






}


    final Mat4x4 translateMat4x4(float x, float y, float z) {
        return new Mat4x4(
            new float[][] {
                {1, 0, 0, x},
                {0, 1, 0, y}, 
                {0, 0, 1, z}, 
                {0, 0, 0, 1}
            }
        );
    }

    final Mat4x4 scaleMat4x4(float x, float y, float z) {
        return new Mat4x4(
            new float[][] {
                {x, 0, 0, 0},
                {0, y, 0, 0}, 
                {0, 0, z, 0}, 
                {0, 0, 0, 1}
            }
        );
    }


    final Mat4x4 rotateXMat4x4(float rad) {
        return new Mat4x4(
            new float[][] {
                {1, 0, 0, 0},
                {0, (float)Math.cos(rad), (float)-Math.sin(rad), 0}, 
                {0, (float)Math.sin(rad), (float)Math.cos(rad), 0}, 
                {0, 0, 0, 1}
            }
        );
    }

    final Mat4x4 rotateYMat4x4(float rad) {
        return new Mat4x4(
            new float[][] {
                {(float)Math.cos(rad), 0, (float)Math.sin(rad), 0},
                {0, 1, 0, 0}, 
                {(float)-Math.sin(rad), 0, (float)Math.cos(rad), 0}, 
                {0, 0, 0, 1}
            }
        );
    }

    final Mat4x4 rotateZMat4x4(float rad) {
        return new Mat4x4(
            new float[][] {
                {(float)Math.cos(rad), (float)-Math.sin(rad), 0, 0},
                {(float)Math.sin(rad), (float)Math.cos(rad), 0, 0}, 
                {0, 0, 1, 0}, 
                {0, 0, 0, 1}
            }
        );
    }

    final Mat4x4 identityMat4x4() {
        return new Mat4x4(
            new float[][] {
                {1, 0, 0, 0},
                {0, 1, 0, 0}, 
                {0, 0, 1, 0}, 
                {0, 0, 0, 1}
            }
        );
    }

    final Mat4x4 zeroMat4x4() {
        return new Mat4x4(
            new float[][] {
                {0, 0, 0, 0},
                {0, 0, 0, 0}, 
                {0, 0, 0, 0}, 
                {0, 0, 0, 0}
            }
        );
    }
