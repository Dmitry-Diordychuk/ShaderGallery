using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] private float moveSpeed;
    [SerializeField] private float rotationSpeed;

    // Update is called once per frame
    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X");
        gameObject.transform.Rotate(Vector3.up, mouseX * Time.deltaTime * rotationSpeed);
    
        Debug.Log(gameObject.transform.forward);
        if (Input.GetKey(KeyCode.W))
        {
            gameObject.transform.Translate(gameObject.transform.forward * (Time.deltaTime * moveSpeed), Space.World);
        }
        else if (Input.GetKey(KeyCode.S))
        {
            gameObject.transform.Translate(-gameObject.transform.forward * (Time.deltaTime * moveSpeed), Space.World);
        }

        if (Input.GetKey(KeyCode.A))
        {
            gameObject.transform.Translate(-gameObject.transform.right * (Time.deltaTime * moveSpeed), Space.World);
        }
        else if (Input.GetKey(KeyCode.D))
        {
            gameObject.transform.Translate(gameObject.transform.right * (Time.deltaTime * moveSpeed), Space.World);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawRay(gameObject.transform.position, gameObject.transform.forward);
    }
}
