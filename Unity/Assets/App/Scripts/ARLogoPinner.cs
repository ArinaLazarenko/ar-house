using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.EnhancedTouch;
using UnityEngine.XR.ARFoundation;

public class ARLogoPinner : MonoBehaviour
{
    private static readonly float noSurfaceMannequinPositionX = 0.5f;
    private static readonly float noSurfaceMannequinPositionY = 0.5f;
    private static readonly float noSurfaceMannequinDistanceFromCamera = 3f;

    public ARRaycastManager raycastManager;
    public GameObject house;

    private bool haveFoundSurface = false;

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
        // Check for touch input
        if (UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches.Count > 0 
        && UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches[0].began)
        {
            house.SetActive(true);
            Console.WriteLine("Touched");
            Vector2 touchPosition = UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches[0].screenPosition;
            Console.WriteLine("Screen position: " + touchPosition.ToString());
            List<ARRaycastHit> hits = new();

            // Perform a raycast from the touch position
            if (raycastManager.Raycast(touchPosition, hits, UnityEngine.XR.ARSubsystems.TrackableType.PlaneWithinPolygon))
            {
                // Surface was detected, use that as the logo position
                house.transform.localPosition = hits[0].pose.position;
                Console.WriteLine("Abs: " + house.transform.position.ToString());
                Console.WriteLine("Local: " + house.transform.localPosition.ToString());
                Console.WriteLine("hit pose: " + hits[0].pose.ToString());

                //float scaleRelativeToDistance = hits[0].distance / 8;
                //flutterLogo.transform.localScale = new Vector3(scaleRelativeToDistance, scaleRelativeToDistance, scaleRelativeToDistance);

                haveFoundSurface = true;
            }
            else if (!haveFoundSurface)
            {
                // No surface detected, use a point straight in front of the camera
                house.transform.position = Camera.main.ViewportToWorldPoint(new Vector3(noSurfaceMannequinPositionX, noSurfaceMannequinPositionY, noSurfaceMannequinDistanceFromCamera));
                //flutterLogo.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
            }
        }
    }
}
