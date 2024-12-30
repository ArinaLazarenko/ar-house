using System.Globalization;
using UnityEngine;

public class ReceiveFromFlutterSize : MonoBehaviour
{
    void Update()
    {
    }

    public void SetScale(string data)
    {
        float scaleFactor = float.Parse(data, CultureInfo.InvariantCulture);
        Vector3 newScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
        transform.localScale = newScale;

    }
}
