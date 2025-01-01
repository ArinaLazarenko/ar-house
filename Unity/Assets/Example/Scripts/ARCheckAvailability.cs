using System.Collections;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Assets.Scripts
{
    public class ARCheckAvailability : MonoBehaviour
    {
        [SerializeField] ARSession arSession;

        void Start() 
        {
            StartCoroutine(CheckAvailabilityCoroutine());
        }

        IEnumerator CheckAvailabilityCoroutine() {
            if ((ARSession.state == ARSessionState.None) ||
                (ARSession.state == ARSessionState.CheckingAvailability) ||
                (ARSession.state == ARSessionState.Installing))
            {
                yield return ARSession.CheckAvailability();
            }

            if (ARSession.state == ARSessionState.Unsupported)
            {
                SendToFlutter.Send("ar:false");
            }
            else
            {
                SendToFlutter.Send("ar:true");
                SendToFlutter.Send("info:This is a two-story modern house with a flat roof and a large balcony on the upper floor, featuring railings across its length. The lower floor includes an open patio area, pillars supporting the structure, and a large garage-style door on the right side.");
            }
        }
    }
}