using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SunRotator : MonoBehaviour {

    private Light sun;
    private Transform sunTransform;
    private bool canRotate;
    private Vector3 rotationVect;
    private int angle;
    private int counter;
    public int speedModifier = 1;

	// Use this for initialization
	void Start () {
        sun = FindObjectOfType<Light>();
        if (sun != null)
        {
            sunTransform = sun.transform;
            canRotate = true;
        }
        else
        {
            Debug.Log("Could not find the 'sun' light object for rotating!");
        }

        rotationVect = new Vector3(1, 0, 0);
        
	}
	
	// Update is called once per frame
	void FixedUpdate () {
        counter++;
        if (counter % speedModifier == 0)
        {
            if (canRotate)
            {
                angle++;
                if (angle > 210)
                {
                    angle = 20;
                }
                Quaternion newRot = Quaternion.AngleAxis(angle, Vector3.right);
                sun.transform.rotation = newRot;
            }

            counter = 0;
        }

        
	}
}
