package fairy.esay.validator;

import android.os.Bundle;
import android.util.Log;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.ReaderException;
import com.google.zxing.Result;
import com.google.zxing.ResultPoint;
import com.google.zxing.ResultPointCallback;
import com.google.zxing.common.HybridBinarizer;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Vector;

import fairy.esay.validator.camera.PlanarYUVLuminanceSource;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    public static final String TAG = "validator";

    private static final String QR_CODE_CHANNEL = "fairy.e.validator/qrcode";
    private static final String QR_CODE_BYTES = "imageStream";
    public static final Vector<BarcodeFormat> PRODUCT_FORMATS;
    public static final Vector<BarcodeFormat> ONE_D_FORMATS;
    public static final Vector<BarcodeFormat> QR_CODE_FORMATS;
    public static final Vector<BarcodeFormat> DATA_MATRIX_FORMATS;

    static {
        PRODUCT_FORMATS = new Vector<BarcodeFormat>(5);
        PRODUCT_FORMATS.add(BarcodeFormat.UPC_A);
        PRODUCT_FORMATS.add(BarcodeFormat.UPC_E);
        PRODUCT_FORMATS.add(BarcodeFormat.EAN_13);
        PRODUCT_FORMATS.add(BarcodeFormat.EAN_8);
        ONE_D_FORMATS = new Vector<BarcodeFormat>(PRODUCT_FORMATS.size() + 4);
        ONE_D_FORMATS.addAll(PRODUCT_FORMATS);
        ONE_D_FORMATS.add(BarcodeFormat.CODE_39);
        ONE_D_FORMATS.add(BarcodeFormat.CODE_93);
        ONE_D_FORMATS.add(BarcodeFormat.CODE_128);
        ONE_D_FORMATS.add(BarcodeFormat.ITF);
        QR_CODE_FORMATS = new Vector<BarcodeFormat>(1);
        QR_CODE_FORMATS.add(BarcodeFormat.QR_CODE);
        DATA_MATRIX_FORMATS = new Vector<BarcodeFormat>(1);
        DATA_MATRIX_FORMATS.add(BarcodeFormat.DATA_MATRIX);
    }

    private MultiFormatReader multiFormatReader;
    private Vector<BarcodeFormat> decodeFormats;

    private void initParam() {
        multiFormatReader = new MultiFormatReader();
        Hashtable<DecodeHintType, Object> hints = new Hashtable<DecodeHintType, Object>();

        if (decodeFormats == null || decodeFormats.isEmpty()) {
            decodeFormats = new Vector<BarcodeFormat>();
            decodeFormats.addAll(ONE_D_FORMATS);
            decodeFormats.addAll(QR_CODE_FORMATS);
            decodeFormats.addAll(DATA_MATRIX_FORMATS);
        }

        hints.put(DecodeHintType.POSSIBLE_FORMATS, decodeFormats);
//        hints.put(DecodeHintType.CHARACTER_SET, "utf-8");
        hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
//        hints.put(DecodeHintType.PURE_BARCODE, Boolean.TRUE);

        hints.put(DecodeHintType.NEED_RESULT_POINT_CALLBACK, new ViewFinderCallBack());

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        initParam();
        MethodChannel channel = new MethodChannel(getFlutterView(), QR_CODE_CHANNEL);
        channel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        switch (call.method) {
                            case QR_CODE_BYTES:
                                runOnFrame((HashMap) call.arguments, result);
                                break;
                            default:
                                result.notImplemented();
                                break;
                        }
                    }
                });

    }

    private void runOnFrame(HashMap args, MethodChannel.Result result) {
        try {
            List<byte[]> bytesList = (List<byte[]>) args.get("cameraBytes");
            ByteBuffer Y = ByteBuffer.wrap(bytesList.get(0));
            ByteBuffer U = ByteBuffer.wrap(bytesList.get(1));
            ByteBuffer V = ByteBuffer.wrap(bytesList.get(2));
            int Yb = Y.remaining();
            int Ub = U.remaining();
            int Vb = V.remaining();

            byte[] data = new byte[Yb + Ub + Vb];

            Y.get(data, 0, Yb);
            V.get(data, Yb, Vb);
            U.get(data, Yb + Vb, Ub);
            decode(data, (Integer) args.get("width"), (Integer) args.get("height"), result);

        } catch (Exception e) {
            result.error(e.toString(), null, null);
        }
    }


    private void decode(byte[] data, int width, int height, MethodChannel.Result result) {
        if (width == 0 || height == 0) {
            result.error("width or height is 0", null, null);
        }

        long start = System.currentTimeMillis();
        Result rawResult = null;
        PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(data, width, height, 0, 0,
                width, height);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
        try {
            rawResult = multiFormatReader.decodeWithState(bitmap);
        } catch (ReaderException e) {
            e.printStackTrace();
        } finally {
            multiFormatReader.reset();
        }
        if (rawResult != null) {
            Log.i(TAG, "耗时" + (System.currentTimeMillis() - start) + "ms");
            result.success(rawResult.getText());
        } else {
            result.success("500");
        }


    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        cancel();
    }

    private void cancel() {
        decodeFormats = null;

    }


    /**
     * 焦点动画
     */
    public static class ViewFinderCallBack implements ResultPointCallback {
        @Override
        public void foundPossibleResultPoint(ResultPoint resultPoint) {

        }
    }
}
