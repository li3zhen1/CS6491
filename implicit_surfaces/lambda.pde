// Lambda expressions for implicit functions
//
// See the "a_sphere" lambda expression for an example of defining an implicit function

import java.lang.FunctionalInterface;

// this is a functional interface that will let us define an implicit function
@FunctionalInterface
interface ImplicitInterface {

  // abstract method that takes (x, y, z) and returns a float
  float getValue(float x, float y, float z);
}


ColoredImplicitInterface shader = null;

@FunctionalInterface
interface ColoredImplicitInterface {
  PVector getColor(float x, float y, float z);
}

// Implicit function for a sphere at the origin.
//
// This may look like a function definition, but it is a lambda expression that we are
// storing in the variable "a_sphere" using =. Note the -> and the semi-colon after the last }

ImplicitInterface a_sphere = (x, y, z) -> {
  float d = sqrt (x*x + y*y + z*z);
  return (d);
};

ImplicitInterface sphereAt(float x0, float y0, float z0, float r) {
  return (x, y, z) -> {
    float d = sqrt((x-x0)*(x-x0) + (y-y0)*(y-y0) + (z-z0)*(z-z0));
    return (d - r);
  };
}

ImplicitInterface b_saucer = (x, y, z) -> {
  y = y * 3;
  float d = sqrt(x*x + y*y + z*z);
  return (d);
};




float blobby(float v) {
  // if (v < 0) return 1;
  if (v > 1) return 0;
  float d = 1 - v * v;
  return d * d * d;
}

class BlobbySpherePreset {
  float r;
  float x;
  float y;
  float z;
  PVector c;
}

class BlobbyGenerator {
  ArrayList<BlobbySpherePreset> presets;
  BlobbyGenerator() {
    presets = new ArrayList<BlobbySpherePreset>();
  }
  
  void add(float r, float x, float y, float z) {
    add(r, x, y, z, new PVector(1, 1, 1));
  }

  void add(float r, float x, float y, float z, PVector c) {
    BlobbySpherePreset p = new BlobbySpherePreset();
    p.r = r;
    p.x = x;
    p.y = y;
    p.z = z;
    p.c = c;
    presets.add(p);
  }

  ImplicitInterface generate() {
    return (x, y, z) -> {
      float result = 0;
      for (BlobbySpherePreset p : presets) {
        float d = sqrt((x-p.x)*(x-p.x) + (y-p.y)*(y-p.y) + (z-p.z)*(z-p.z));
        result += blobby(d/p.r);
      }
      return result;
    };
  }
  ColoredImplicitInterface generateColor() {
    return (x, y, z) -> {
      float result = 0;
      float[] blobbyResults = new float[presets.size()];
      for (BlobbySpherePreset p : presets) {
        float d = sqrt((x-p.x)*(x-p.x) + (y-p.y)*(y-p.y) + (z-p.z)*(z-p.z));
        blobbyResults[presets.indexOf(p)] = blobby(d/p.r);
        result += blobbyResults[presets.indexOf(p)];
      }
      float r = 0;
      float g = 0;
      float b = 0;
      for (BlobbySpherePreset p : presets) {
        float d = blobbyResults[presets.indexOf(p)] / result * 255;
        r += p.c.x * d;
        g += p.c.y * d;
        b += p.c.z * d;
      }
      return new PVector(r, g, b);
    };
  }
}


class LineSegmentGenerator {
  PVector from;
  PVector to;

  LineSegmentGenerator(PVector from, PVector to) {
    this.from = from;
    this.to = to;
  }

  ImplicitInterface generate() {
    return (x, y, z) -> {
      PVector p = new PVector(x, y, z);
      PVector a = from;
      PVector b = to;
      PVector pa = p.copy().sub(a);
      PVector ba = b.copy().sub(a);
      float h = pa.dot(ba) / ba.dot(ba);
      if (h < 0) h = 0;
      if (h > 1) h = 1;
      PVector projection = a.copy().add(ba.copy().mult(h));
      float d = p.copy().sub(projection).mag();
      return d;
    };
  }

  ImplicitInterface generate(float threshold) {
    return (x, y, z) -> {
      PVector p = new PVector(x, y, z);
      PVector a = from;
      PVector b = to;
      PVector pa = p.copy().sub(a);
      PVector ba = b.copy().sub(a);
      float h = pa.dot(ba) / ba.dot(ba);
      if (h < 0) h = 0;
      if (h > 1) h = 1;
      PVector projection = a.copy().add(ba.copy().mult(h));
      float d = p.copy().sub(projection).mag();
      return d - threshold;
    };
  }
}

class TorusGenerator {
  float R;
  float r;

  TorusGenerator(float R, float r) {
    this.r = r;
    this.R = R;
  }

  ImplicitInterface generate() {
    // (x^2 + y^2 + z^2 + R^2 - r^2)^2 - 4R^2 (x^2 + y^2)
    return (x, y, z) -> {
      float d = (x*x + y*y + z*z + R*R - r*r)*(x*x + y*y + z*z + R*R - r*r) - 4*R*R*(x*x + y*y);
      return d;
    };
  }

  // ImplicitInterface generate2() {
  //   return (x, y, z) -> {
      
  //   };
  // }
}

ImplicitInterface transform(
  ImplicitInterface surface,
  PMatrix3D matrix
) {
  return (x, y, z) -> {
    PVector p = new PVector(x, y, z);
    matrix.mult(p, p);
    return surface.getValue(p.x, p.y, p.z);
  };
}

ImplicitInterface intersectionOf(
  ImplicitInterface a,
  ImplicitInterface b
) {
  return (x, y, z) -> {
    return max(a.getValue(x, y, z), b.getValue(x, y, z));
  };
}

ImplicitInterface substractionOf(
  ImplicitInterface a,
  ImplicitInterface b
) {
  return (x, y, z) -> {
    return max(a.getValue(x, y, z), -b.getValue(x, y, z));
  };
}

class SealedImplicitInterface {
  ImplicitInterface surface;
  float threshold;

  SealedImplicitInterface(ImplicitInterface surface, float threshold) {
    this.surface = surface;
    this.threshold = threshold;
  }
}


class ImplicitInterfaceBlobbyGenerator {

  ArrayList< SealedImplicitInterface > surfaces;

  ImplicitInterfaceBlobbyGenerator() {
    surfaces = new ArrayList< SealedImplicitInterface >();
  }
  
  ImplicitInterfaceBlobbyGenerator add(ImplicitInterface surface, float threshold) {
    surfaces.add(new SealedImplicitInterface(surface, threshold));
    return this;
  }

  ImplicitInterface generate() {
    return (x, y, z) -> {
      float result = 0;
      for (SealedImplicitInterface p : surfaces) {
        result += blobby(p.surface.getValue(x, y, z) / p.threshold);
      }
      return result;
    };
  }

  ImplicitInterface seal() {
    return (x, y, z) -> {
      float result = Float.MIN_VALUE;
      for (SealedImplicitInterface p : surfaces) {
        var value = p.surface.getValue(x, y, z);
        if (value > result) {
          result = value;
        }
      }
      return result;
    };
  }
}

float eps = 0.005;


ImplicitInterface twistOnX(ImplicitInterface surf, float ratio) {
  return (x, y, z) -> {
    float _cos = cos(ratio*x);
    float _sin = sin(ratio*x);
    float _y = _cos * y - _sin * z;
    float _z = _sin * y + _cos * z;

    return surf.getValue(x, _y, _z);
  };
}

ImplicitInterface taperOnX(ImplicitInterface surf, float xMin, float xMax, float k1, float k2) {
  return (x, y, z) -> {
    float t;
    if (x < xMin) {
      t = 0;
    } else if (x > xMax) {
      t = 1;
    } else {
      t = (x - xMin) / (xMax - xMin);
    }

    float k = (1 - t) * k1 + t * k2;

    return surf.getValue(x, y/k, z/k);
  };
}

PVector gradient_at(ImplicitInterface surf, float x, float y, float z) {
  float dx = surf.getValue(x + eps, y, z) - surf.getValue(x - eps, y, z);
  float dy = surf.getValue(x, y + eps, z) - surf.getValue(x, y - eps, z);
  float dz = surf.getValue(x, y, z + eps) - surf.getValue(x, y, z - eps);
  return new PVector(dx, dy, dz).normalize();
}