using System.Globalization;
using UnityEngine;
using System; 

public class ReceiveFromFlutterPosition : MonoBehaviour
{
    public ARLogoPinner arLogoPinner;
    public Camera camera;

    public float speed = 1.0f;

    //public void SetPosition(string data)
    //{
    //    string[] values = data.Split(',');
    //    if (values.Length == 3)
    //    {
    //        float x = float.Parse(values[0], CultureInfo.InvariantCulture);
    //        float y = float.Parse(values[1], CultureInfo.InvariantCulture);
    //        float z = float.Parse(values[2], CultureInfo.InvariantCulture);

    //        Vector3 newPosition = new Vector3(x, y, z);
    //        transform.position = newPosition;
    //    }
    //}

    public void SetDirection(string data)
    {
        string[] values = data.Split(',');
        if (values.Length == 3)
        {
            float x = float.Parse(values[0], CultureInfo.InvariantCulture);
            float y = float.Parse(values[1], CultureInfo.InvariantCulture);
            float z = float.Parse(values[2], CultureInfo.InvariantCulture);
            Vector3 inputDirection = new Vector3(x, y, z);
            var forwardProjection = new Vector3(camera.transform.forward.x, 0, camera.transform.forward.z);
            var rightProjection = new Vector3(camera.transform.right.x, 0, camera.transform.right.z);
            Vector3 moveDirection = forwardProjection * inputDirection.z + rightProjection * inputDirection.x;

            transform.position += moveDirection * speed * Time.deltaTime;
        }
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
