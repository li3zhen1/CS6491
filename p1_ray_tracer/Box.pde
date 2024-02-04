Box createBoxChecked(PVector pMin, PVector pMax) {
    if (pMin.x > pMax.x) {
        float temp = pMin.x;
        pMin.x = pMax.x;
        pMax.x = temp;
    }
    if (pMin.y > pMax.y) {
        float temp = pMin.y;
        pMin.y = pMax.y;
        pMax.y = temp;
    }
    if (pMin.z > pMax.z) {
        float temp = pMin.z;
        pMin.z = pMax.z;
        pMax.z = temp;
    }
    return new Box(pMin, pMax);
}



final class Box implements IPrimitive {
    final PVector pMin;
    final PVector pMax;
    final PVector centroid;

    Box(PVector pMin, PVector pMax) {
        this.pMin = pMin;
        this.pMax = pMax;
        this.centroid = new PVector((pMin.x + pMax.x) / 2, (pMin.y + pMax.y) / 2, (pMin.z + pMax.z) / 2);
    }

    Box getBoundingBox() {
        return this;
    }



    final boolean hasIntersection(Ray ray, float mint, float maxt) {
        float t0 = mint;
        float t1 = maxt;

        float txMin = (pMin.x - ray.origin.x) / ray.direction.x;
        float txMax = (pMax.x - ray.origin.x) / ray.direction.x;
        if (txMin > txMax) {
            float temp = txMin;
            txMin = txMax;
            txMax = temp;
        }
        if (txMin > t0) {
            t0 = txMin;
        }
        if (txMax < t1) {
            t1 = txMax;
        }
        if (t0 > t1) {
            return false;
        }

        float tyMin = (pMin.y - ray.origin.y) / ray.direction.y;
        float tyMax = (pMax.y - ray.origin.y) / ray.direction.y;
        if (tyMin > tyMax) {
            float temp = tyMin;
            tyMin = tyMax;
            tyMax = temp;
        }
        if (tyMin > t0) {
            t0 = tyMin;
        }
        if (tyMax < t1) {
            t1 = tyMax;
        }
        if (t0 > t1) {
            return false;
        }

        float tzMin = (pMin.z - ray.origin.z) / ray.direction.z;
        float tzMax = (pMax.z - ray.origin.z) / ray.direction.z;
        if (tzMin > tzMax) {
            float temp = tzMin;
            tzMin = tzMax;
            tzMax = temp;
        }
        if (tzMin > t0) {
            t0 = tzMin;
        }
        if (tzMax < t1) {
            t1 = tzMax;
        }
        if (t0 > t1) {
            return false;
        }
        // println("t0: " + t0 + " t1: " + t1);
        return t0 <= maxt && t1 >= mint;
    }

    PartialHit _getIntersection(Ray ray, SceneGraph sg) {


        // boolean hasIntersection = false;
        
        int hitAxis = 0; // 1 = x, 2 = y, 3 = z        
        float t0 = 0;
        float t1 = Float.MAX_VALUE;
        boolean xFlipped = false;
        boolean yFlipped = false;
        boolean zFlipped = false;


        float txMin = (pMin.x - ray.origin.x) / ray.direction.x;
        float txMax = (pMax.x - ray.origin.x) / ray.direction.x;
        if (txMin >= txMax) {
            float temp = txMin;
            txMin = txMax;
            txMax = temp;
            xFlipped = true;
        }
        if (txMin > t0) {
            t0 = txMin;
            hitAxis = 1;
        }
        if (txMax < t1) {
            t1 = txMax;
        }
        if (t0 > t1 + EPSILON) {
            return null;
        }

        float tyMin = (pMin.y - ray.origin.y) / ray.direction.y;
        float tyMax = (pMax.y - ray.origin.y) / ray.direction.y;
        if (tyMin >= tyMax) {
            float temp = tyMin;
            tyMin = tyMax;
            tyMax = temp;
            yFlipped = true;
        }
        if (tyMin > t0) {
            t0 = tyMin;
            hitAxis = 2;
        }
        if (tyMax < t1) {
            t1 = tyMax;
        }
        // if (debug_flag) {
        //     println("t0: " + t0 + " t1: " + t1);
        //     println("pMin: " + pMin + " pMax: " + pMax);
        //     println("ray: " + ray.origin + " " + ray.direction);
        //     println("txMin: " + txMin + " txMax: " + txMax);
        //     println("yFlipped: " + xFlipped);
        //     println("t0 > t1: " + (t0 > t1));
        // }
        if (t0 > t1 + EPSILON) {
            return null;
        }


        float tzMin = (pMin.z - ray.origin.z) / ray.direction.z;
        float tzMax = (pMax.z - ray.origin.z) / ray.direction.z;
        if (tzMin >= tzMax) {
            float temp = tzMin;
            tzMin = tzMax;
            tzMax = temp;
            zFlipped = true;
        }
        if (tzMin > t0) {
            t0 = tzMin;
            hitAxis = 3;
        }
        if (tzMax < t1) {
            t1 = tzMax;
        }
        if (t0 > t1 + EPSILON) {
            return null;
        }

        if (t1 < 0.0) {
            return null;
        }

        PVector pHit = ray.getPosition(t0);
        PVector normal = new PVector(0, 0, 0);
        if (hitAxis == 1) {
            if (xFlipped) {
                normal.x = 1;
            } else {
                normal.x = -1;
            }
        } else if (hitAxis == 2) {
            if (yFlipped) {
                normal.y = 1;
            } else {
                normal.y = -1;
            }
        } else if (hitAxis == 3) {
            if (zFlipped) {
                normal.z = 1;
            } else {
                normal.z = -1;
            }
        }
        
        return new PartialHit(pHit, normal, t0, t1);

        // var resultColor = new Color(0.0, 0.0, 0.0);
        

        // for(int i = 0; i < sg.lights.size(); i++) {
        //     Light light = sg.lights.get(i);
        //     PVector lightDir = PVector.sub(light.position, pHit);
        //     PVector lightDirNormalized = lightDir.normalize();
        //     // println(lightDir, "-->", lightDirNormalized);
        //     float length = PVector.dist(light.position, pHit);
        //     Ray shadowRay = new Ray(pHit, lightDirNormalized /*lightDir.length()*/);
        //     boolean hasOcclusionTowardsThisRay = false;
        //     for(int j = 0; j < sg.secneObjectInstances.size(); j++) {
        //         IRenderableObject object = sg.secneObjectInstances.get(j);
        //         if (object.hasIntersection(shadowRay, EPSILON, length /*lightDir.length()*/)) {
        //             hasOcclusionTowardsThisRay = true;
        //             break;
        //         }
        //     }
        //     if (!hasOcclusionTowardsThisRay) {
        //         float cosTheta = normal.dot(lightDirNormalized);
        //         // println("cosTheta: " + cosTheta);
        //         if (cosTheta < 0) {
        //             cosTheta = -cosTheta;
        //         }
        //         resultColor.r += diffuseColor.r * light._color.r * cosTheta;
        //         resultColor.g += diffuseColor.g * light._color.g * cosTheta;
        //         resultColor.b += diffuseColor.b * light._color.b * cosTheta;
        //     }
        // }

        // return new Hit(pHit, normal, resultColor);

    } 

    void dump() {
        println("Box: " + pMin + " " + pMax);
    }




}

    Box union(Box b1, Box b2) {
        Box result = new Box(b1.pMin, b1.pMax);
        result.pMin.x = min(b1.pMin.x, b2.pMin.x);
        result.pMin.y = min(b1.pMin.y, b2.pMin.y);
        result.pMin.z = min(b1.pMin.z, b2.pMin.z);
        result.pMax.x = max(b1.pMax.x, b2.pMax.x);
        result.pMax.y = max(b1.pMax.y, b2.pMax.y);
        result.pMax.z = max(b1.pMax.z, b2.pMax.z);
        return result;
    }