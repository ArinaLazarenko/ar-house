using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using System;
using UnityEngine.InputSystem.EnhancedTouch;

public class ARLogoPinner : MonoBehaviour
{
    private static readonly float cursorRaycastX = 0.5f;
    private static readonly float cursorRaycastY = 0.2f;
    private static readonly float noSurfaceMannequinPositionX = 0.5f;
    private static readonly float noSurfaceMannequinPositionY = 0.5f;
    private static readonly float noSurfaceMannequinDistanceFromCamera = 3f;

    public ARRaycastManager raycastManager;
    public GameObject flutterLogo;

    private bool haveFoundSurface = false;
    private bool controlledByFlutter = false;

    void Awake()
    {
        // Required for input polling in new input system
        EnhancedTouchSupport.Enable();
    }

    void OnDestroy()
    {
        EnhancedTouchSupport.Disable();
    }


    void Update()
    {
        if (UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches.Count > 0
        && UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches[0].began)
        {

            flutterLogo.SetActive(true);
            Console.WriteLine("Touched");
            Vector2 touchPosition = UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches[0].screenPosition;
            Console.WriteLine("Screen position: " + touchPosition.ToString());
            List<ARRaycastHit> hits = new();

            // Perform a raycast from the touch position
            if (raycastManager.Raycast(touchPosition, hits, UnityEngine.XR.ARSubsystems.TrackableType.PlaneWithinPolygon))
            {
                // Surface was detected, use that as the logo position
                flutterLogo.transform.localPosition = hits[0].pose.position;
                Console.WriteLine("Abs: " + flutterLogo.transform.position.ToString());
                Console.WriteLine("Local: " + flutterLogo.transform.localPosition.ToString());
                Console.WriteLine("hit pose: " + hits[0].pose.ToString());

                haveFoundSurface = true;
            }
            else if (!haveFoundSurface)
            {
                flutterLogo.transform.position = Camera.main.ViewportToWorldPoint(new Vector3(noSurfaceMannequinPositionX, noSurfaceMannequinPositionY, noSurfaceMannequinDistanceFromCamera));
            }
        }
    }

    public void SetControlledByFlutter(bool enabled)
    {
        controlledByFlutter = enabled;
    }
}
