using System.Globalization;
using UnityEngine;
using System; 

public class ReceiveFromFlutterScale : MonoBehaviour
{
    public ARLogoPinner arLogoPinner;

    public void SetScale(string data)
    {
        float scaleFactor = float.Parse(data, CultureInfo.InvariantCulture);
        Vector3 newScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
        transform.localScale = newScale;
    }

    public void SetControlledByFlutter(string value)
    {
        if (arLogoPinner == null)
        {
            return;
        }
        
        bool isControlled = value.Equals("true", StringComparison.OrdinalIgnoreCase);
        arLogoPinner.SetControlledByFlutter(isControlled);
    }
}
