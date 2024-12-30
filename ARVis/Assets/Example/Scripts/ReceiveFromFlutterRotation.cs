using System.Globalization;
using UnityEngine;

public class ReceiveFromFlutterRotation : MonoBehaviour
{
    void Update()
    {
    }

    public void SetRotation(string data)
    {
        float targetRotationAngle = float.Parse(data, CultureInfo.InvariantCulture);
        Quaternion targetRotation = Quaternion.Euler(0, targetRotationAngle, 0);
        transform.rotation = targetRotation;

    }
}
