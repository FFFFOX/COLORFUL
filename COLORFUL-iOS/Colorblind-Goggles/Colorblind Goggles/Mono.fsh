precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform highp float factor;

float minMaxRGB(float val){
    if(val < 0.0)
    {
        return 0.0;
    }
    if(val > 255.0)
    {
        return 255.0;
    }
    return val;
}

void main(){
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 outputColor;
    
    highp float R;
    highp float G;
    highp float B;
    highp float L;
    highp float M;
    highp float S;
    highp float Lmin;
    highp float Lmax;
    highp float Lrange;
    highp float Mmin;
    highp float Mmax;
    highp float Mrange;
    highp float Smin;
    highp float Smax;
    highp float Srange;
    
    
    R = float(textureColor.r);
    G = float(textureColor.g);
    B = float(textureColor.b);
    
    Lmax = (17.8824 * (R)) + (43.5161 * (G)) + (4.11935 * (B));
    Mmax = (3.45565 * (R)) + (27.1554 * (G)) + (3.86714 * (B));
    Smax = (0.0299566 * (R)) + (0.184309 * (G)) + (1.46709 * (B));
    
    Smin = (0.05 * (Mmax));
    Mmin = (0.494207 * (Lmax)) + (0.0 * (Mmax)) + (1.24827 * (Smin));
    Lmin = (0.0 * (Lmax)) + (2.02344 * (Mmin)) - (2.52581 * (Smin));
    Smin = (0.05 * (Mmin));
    Mmin = (0.494207 * (Lmin)) + (0.0 * (Mmin)) + (1.24827 * (Smin));
    Lmin = (0.0 * (Lmin)) + (2.02344 * (Mmin)) - (2.52581 * (Smin));
    
    Lrange = (Lmax - Lmin)/100.00;
    L = Lmax - (Lrange * factor);
    Mrange = (Mmax - Mmin)/100.00;
    M = Mmax - (Mrange * factor);
    Srange = (Smax - Smin)/100.00;
    S = Smax - (Srange * factor);
    
    R = (0.080944 * (L)) - (0.130504 * (M)) + (0.116721 * (S));
    G = (-0.0102485 * (L)) + (0.0540194 * (M)) - (0.113615 * (S));
    B = (-0.000365294 * (L)) - (0.00412163 * (M)) + (0.693513 * (S));
    
    outputColor.r = minMaxRGB(R);
    outputColor.g = minMaxRGB(G);
    outputColor.b = minMaxRGB(B);
    outputColor.a = 1.0;
    
    gl_FragColor = outputColor;
}

